From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] tcp: use RTAX_CWND for outgoing connections properly
Date: Wed, 22 Dec 2010 15:07:43 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012221506500.16569@pobox.suse.cz>
References: <alpine.LNX.2.00.1012172310400.16569@pobox.suse.cz>  <alpine.LNX.2.00.1012221059340.16569@pobox.suse.cz> <1293017383.3027.75.camel@edumazet-laptop> <alpine.LNX.2.00.1012221231450.16569@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Vojtech Pavlik <vojtech@suse.cz>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44359 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752684Ab0LVOHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Dec 2010 09:07:48 -0500
In-Reply-To: <alpine.LNX.2.00.1012221231450.16569@pobox.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Dec 2010, Jiri Kosina wrote:

> > 12:13:46.855786 IP 192.168.20.110.39146 > 192.168.20.108.59636: S 1615862982:1615862982(0) win 14600 <mss 1460,sackOK,timestamp 277530 0,nop,wscale 8>
> > 12:13:46.855807 IP 192.168.20.108.59636 > 192.168.20.110.39146: S 1603053412:1603053412(0) ack 1615862983 win 14480 <mss 1460,sackOK,timestamp 744840 277530,nop,wscale 7>
> > 12:13:46.855878 IP 192.168.20.110.39146 > 192.168.20.108.59636: . ack 1 win 58 <nop,nop,timestamp 277530 744840>
> > 12:13:46.856779 IP 192.168.20.110.39146 > 192.168.20.108.59636: P 1:14481(14480) ack 1 win 58 <nop,nop,timestamp 277530 744840>
> > 12:13:46.856794 IP 192.168.20.108.59636 > 192.168.20.110.39146: . ack 14481 win 136 <nop,nop,timestamp 744841 277530>
> > 12:13:46.856901 IP 192.168.20.110.39146 > 192.168.20.108.59636: . 14481:15929(1448) ack 1 win 58 <nop,nop,timestamp 277531 744841>
> > 12:13:46.856912 IP 192.168.20.108.59636 > 192.168.20.110.39146: . ack 15929 win 159 <nop,nop,timestamp 744841 277531>
> > 12:13:46.856930 IP 192.168.20.110.39146 > 192.168.20.108.59636: . 15929:18825(2896) ack 1 win 58 <nop,nop,timestamp 277531 744841>
> >
> > We can see 192.168.20.110 sends 14480 bytes in its first frame.
> 
> So is this with 356f039822b8d802138f applied?
> 
> I have had a testing environment in which I had forced the 'receiver' to 
> advertise large receive window, but still the sender started with a very 
> small initial congestion window, waiting for ack after 1 or 2 MSS-sized 
> packets.

OK, so current vanilla (not even net-next needed) seems to correctly 
handle initcwnd value and sends as many packets as fit into it, instead of 
waiting after one or two MSS-sized packets. So someone already fixed it 
in some other way apparently. Sorry for the noise.

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
