From: Bernhard Schmidt <berni@birkenwald.de>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after
	some time
Date: Tue, 9 Sep 2008 12:06:20 +0200
Message-ID: <20080909100620.GA18584@pest>
References: <63ca0b47d6921cd641bb3ca26ab20baa@chewa.net> <OF3335B3DD.83510AA3-ON882574BF.00275BAF-882574BF.00281037@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <rdenis@simphalempin.com>,
	Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs02.svr02.mucip.net ([83.170.6.69]:49446 "EHLO
	mailout.mucip.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbYIIKGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 06:06:24 -0400
Content-Disposition: inline
In-Reply-To: <OF3335B3DD.83510AA3-ON882574BF.00275BAF-882574BF.00281037@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 09, 2008 at 12:17:35AM -0700, David Stevens wrote:
> netdev-owner@vger.kernel.org wrote on 09/08/2008 11:52:05 PM:
> 
> > 
> > On Tue, 9 Sep 2008 02:38:53 +0200, Bernhard Schmidt 
> <berni@birkenwald.de>
> > 
> > wrote:
> > 
> > > ff00::/8 dev teredo  metric 256  mtu 1280 advmss 1220 hoplimit 
> 4294967295
> > 
> >                ^^^^^^
> > 
> > Uho... that interface is not multicast-capable. Not sure how the kernel
> > handles the conflicting routes.
> 
>         Multicast programs shouldn't rely on the routing
> table at all, IMAO. Unicast routing has nothing at all
> to do with multicast routing, where a single address
> means copying and forwarding to multiple different
> segments, and the address has nothing at all to do with
> the routing topology.

I agree with you that it should not rely on it. However, it obviously
did (in some way):

miredo:~# ip -6 route del ff00::/8 dev teredo  metric 256  mtu 1280 advmss 1220 hoplimit 4294967295                           
miredo:~# ping6 -I eth0 ff02::9
PING ff02::9(ff02::9) from fe80::216:3eff:feb9:29f5 eth0: 56 data bytes
64 bytes from fe80::216:3eff:feb9:29f5: icmp_seq=1 ttl=64 time=0.098 ms
64 bytes from fe80::2c0:9fff:fe4b:8ccf: icmp_seq=1 ttl=64 time=0.453 ms (DUP!)
64 bytes from fe80::20c:86ff:fe9a:3819: icmp_seq=1 ttl=64 time=0.467 ms (DUP!)
64 bytes from fe80::20c:86ff:fe9a:2819: icmp_seq=1 ttl=64 time=0.472 ms (DUP!)

I'm not convinced that this route was the culprit though, I think it
might be related to some sort of routing-table locking foo that got
resolved when I changed something. I'll keep it running (will take one
or two days max to reappear) and try deleting an arbitrary route when it
happens again.

Bernhard
