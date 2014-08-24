From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/3] Basic deferred TX queue flushing infrastructure.
Date: Sun, 24 Aug 2014 10:37:48 -0700
Message-ID: <1408901868.5604.60.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140823.132811.751469424156827125.davem@davemloft.net>
	 <20140823.213839.1953243016141233125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	hannes@stressinduktion.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:64367 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643AbaHXRhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 13:37:53 -0400
Received: by mail-pd0-f182.google.com with SMTP id fp1so18795864pdb.27
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2014 10:37:49 -0700 (PDT)
In-Reply-To: <20140823.213839.1953243016141233125.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-08-23 at 21:38 -0700, David Miller wrote:

> Like Tom Herbert has mentioned we have all the infrastructure (sort
> of) already to handle a list of SKBs going down into
> dev_hard_start_xmit() via the GSO handling.
> 
> But that code is funny, because it keeps the original GSO head SKB
> around as a placeholder to maintain the list of segmented SKBs.

This is because dev_hard_start_xmit() do not return an skb, but a rc
code.

int ret = dev_hard_start_xmit(skb, dev, txq);

That can be changed so that we do not have to keep the original skb as
the GSO head :

sch_direct_xmit() would 'requeue' the new skb (might be in the middle of
the skb segmented chain), not the original one.

This would get rid of DEV_GSO_CB() presumably.
