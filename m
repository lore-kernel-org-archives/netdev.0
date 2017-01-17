From: Andrew Collins <acollins@cradlepoint.com>
Subject: fq_codel and skb->hash
Date: Mon, 16 Jan 2017 17:04:44 -0700
Message-ID: <f9913fca-da16-8620-d237-d7d8d09cced2@cradlepoint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <edumazet@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0138.outbound.protection.outlook.com ([104.47.32.138]:61511
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751012AbdAQAEw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 19:04:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fq_codel packet scheduler always regenerates the skb flow hash.  Is there any reason
to do this other than the recent hash perturbation additions?

I ask because I have a case where an incoming set of TCP flows is encapsulated in a
single ipsec tunnel, which is then classified on egress into a single flow by fq_codel
resulting in poor behavior.

Reusing the skb hash set in receive results in much better behavior, as the value is
determined pre-encapsulation and flows end up being distributed more naturally across
codel queues.

Is opportunistically using the pre-existing skb hash (if available) problematic?  Is
there a better way to manage flow separation in routed+encapsulated traffic?

Thanks,
Andrew Collins
