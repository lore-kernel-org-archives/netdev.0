From: Daniel Phillips <phillips@google.com>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Date: Sun, 13 Aug 2006 14:22:31 -0700
Message-ID: <44DF9817.8070509@google.com>
References: <44D976E6.5010106@google.com>	<20060809131942.GY14627@postel.suug.ch>	<1155132440.12225.70.camel@twins> <20060809.165846.107940575.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: a.p.zijlstra@chello.nl, tgraf@suug.ch, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.12]:16235 "EHLO
	smtp-out.google.com") by vger.kernel.org with ESMTP
	id S1751479AbWHMVWt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 17:22:49 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060809.165846.107940575.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
>>Hmm, what does sk_buff::input_dev do? That seems to store the initial
>>device?
> 
> You can run grep on the tree just as easily as I can which is what I
> did to answer this question.  It only takes a few seconds of your
> time to grep the source tree for things like "skb->input_dev", so
> would you please do that before asking more questions like this?
> 
> It does store the initial device, but as Thomas tried so hard to
> explain to you guys these device pointers in the skb are transient and
> you cannot refer to them outside of packet receive processing.

Thomas did a great job of explaining and without any flaming or ad
hominem attacks.

We have now formed a decent plan for doing the accounting in a stable
way without adding new fields to sk_buff, thankyou for the catch.

> The reason is that there is no refcounting performed on these devices
> when they are attached to the skb, for performance reasons, and thus
> the device can be downed, the module for it removed, etc. long before
> the skb is freed up.

The virtual block device can refcount the network device on virtual
device create and un-refcount on virtual device delete.  We need to
add that to the core patch and maybe package it nicely so the memalloc
reserve/unreserve happens at the same time, in a tidy little library
function to share with other virtual devices like iSCSI that also need
some anti-deadlock lovin.

Regards,

Daniel
