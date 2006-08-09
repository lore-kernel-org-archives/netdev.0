From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Date: Wed, 09 Aug 2006 18:19:54 +0200
Message-ID: <1155140394.12225.88.camel@twins>
References: <20060808193345.1396.16773.sendpatchset@lappy>
	 <20060808211731.GR14627@postel.suug.ch> <44D93BB3.5070507@google.com>
	 <20060808.183920.41636471.davem@davemloft.net>
	 <44D976E6.5010106@google.com> <20060809131942.GY14627@postel.suug.ch>
	 <1155132440.12225.70.camel@twins>  <20060809161816.GA14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Phillips <phillips@google.com>,
	David Miller <davem@davemloft.net>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:49064 "EHLO
	amsfep12-int.chello.nl") by vger.kernel.org with ESMTP
	id S1750767AbWHIQYZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 12:24:25 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060809161816.GA14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-09 at 18:18 +0200, Thomas Graf wrote:
> * Peter Zijlstra <a.p.zijlstra@chello.nl> 2006-08-09 16:07
> > I think Daniel was thinking of adding struct net_device *
> > sk_buff::alloc_dev,
> > I know I was after reading the first few mails. However if adding a
> > field 
> > there is strict no-no....
> > 
> > /me takes a look at struct sk_buff
> > 
> > Hmm, what does sk_buff::input_dev do? That seems to store the initial
> > device?
> 
> No, skb->input_dev is used when redirecting packets around in the
> stack and may change. Even if it would keep its value the reference
> to the netdevice is not valid anymore when you free the skb as the
> skb was queued and the refcnt acquired in __netifx_rx_schedule()
> has been released again thus making it possible for the netdevice
> to disappear.

Bah, tricky stuff that.

disregards this part from -v2 then :-(


