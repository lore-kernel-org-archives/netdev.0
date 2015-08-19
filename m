From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v2 0/3] add TSO / A-MSDU TX for iwlwifi
Date: Wed, 19 Aug 2015 07:14:07 -0700
Message-ID: <1439993647.6610.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439989181-4444-1-git-send-email-emmanuel.grumbach@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, ido@wizery.com,
	netdev@vger.kernel.org
To: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:32793 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157AbbHSOOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 10:14:11 -0400
In-Reply-To: <1439989181-4444-1-git-send-email-emmanuel.grumbach@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-08-19 at 15:59 +0300, Emmanuel Grumbach wrote:

> We could have enabled A-MSDU based on xmit-more, but the
> rationale of using LSO is that when using pfifo-fast,
> the Qdisc gets one packet and dequeues is straight away
> which limits the possibility to get a lot of packets at
> once. (Am I right here?).

No, you are not ;)

Key point for xmit_more is BQL being implemented in your driver.

Relevant code is in try_bulk_dequeue_skb()
