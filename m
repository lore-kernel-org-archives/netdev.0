From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 22:08:12 +0200
Message-ID: <20060630200812.GM14627@postel.suug.ch>
References: <20060630130811.GE14627@postel.suug.ch> <1151675843.5270.18.camel@jzny2> <20060630141531.GG14627@postel.suug.ch> <1151678118.5270.45.camel@jzny2> <20060630163229.GH14627@postel.suug.ch> <20060630171348.GI14627@postel.suug.ch> <44A55CF8.2040509@trash.net> <1151688732.5270.101.camel@jzny2> <20060630174251.GK14627@postel.suug.ch> <1151696083.5270.218.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:21949 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750748AbWF3UHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 16:07:51 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151696083.5270.218.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-06-30 15:34
> I thought we went past that point already - and i made it clear that
> the reference is _not_ taken in netif_receive_skb().
> 
> So assuming it is taken in mirred (i havent thought of where it is
> decremented), why would using the ifindex be better?

The issue exists regardless of mirred/ifb. As soon as the packet is
queued for the first time we leave netif_receive_skb() and the dev
reference is dropped. Therefore in order to allow functionality
like tcf_match_indev() at egress we have to either take a reference
or ensure that we can catch the unlikely case of the device having
disappeared. I think everyone would agree to use device pointers
if only mirred would acquire it.
