From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Date: Wed, 09 Aug 2006 16:58:46 -0700 (PDT)
Message-ID: <20060809.165846.107940575.davem@davemloft.net>
References: <44D976E6.5010106@google.com>
	<20060809131942.GY14627@postel.suug.ch>
	<1155132440.12225.70.camel@twins>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, phillips@google.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:56964
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932065AbWHIX6z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 19:58:55 -0400
To: a.p.zijlstra@chello.nl
In-Reply-To: <1155132440.12225.70.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 09 Aug 2006 16:07:20 +0200

> Hmm, what does sk_buff::input_dev do? That seems to store the initial
> device?

You can run grep on the tree just as easily as I can which is what I
did to answer this question.  It only takes a few seconds of your
time to grep the source tree for things like "skb->input_dev", so
would you please do that before asking more questions like this?

It does store the initial device, but as Thomas tried so hard to
explain to you guys these device pointers in the skb are transient and
you cannot refer to them outside of packet receive processing.

The reason is that there is no refcounting performed on these devices
when they are attached to the skb, for performance reasons, and thus
the device can be downed, the module for it removed, etc. long before
the skb is freed up.
