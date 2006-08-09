From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Date: Tue, 08 Aug 2006 18:39:20 -0700 (PDT)
Message-ID: <20060808.183920.41636471.davem@davemloft.net>
References: <20060808193345.1396.16773.sendpatchset@lappy>
	<20060808211731.GR14627@postel.suug.ch>
	<44D93BB3.5070507@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, a.p.zijlstra@chello.nl, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:12262
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030404AbWHIBjy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 21:39:54 -0400
To: phillips@google.com
In-Reply-To: <44D93BB3.5070507@google.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Phillips <phillips@google.com>
Date: Tue, 08 Aug 2006 18:34:43 -0700

> Can you please characterize the conditions under which skb->dev changes
> after the alloc?  Are there writings on this subtlety?

The packet scheduler and classifier can redirect packets to different
devices, and can the netfilter layer.

The setting of skb->dev is wholly transient and you cannot rely upon
it to be the same as when you set it on allocation.

Even simple things like the bonding device change skb->dev on every
receive.

I think you need to study the networking stack a little more before
you continue to play in this delicate area :-)
