From: Petr Baudis <pasky@xs26.net>
Subject: Re: addrconf.c - possible bug
Date: Mon, 15 Apr 2002 21:22:48 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020415192248.GB3218@pasky.ji.cz>
References: <20020323165921.GC1954@pasky.ji.cz> <Pine.LNX.4.44.0203231906560.29954-100000@netcore.fi> <20020323184451.GD1954@pasky.ji.cz> <20020324195737.GM1954@pasky.ji.cz> <20020331191346.GI1954@pasky.ji.cz>
Reply-To: xs26-dev@xs26.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xs26-dev@xs26.net, Pekka Savola <pekkas@netcore.fi>,
   Jan Oravec <jan.oravec@xs26.net>, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <owner-netdev@oss.sgi.com>
To: Petr Baudis <pasky@xs26.net>
Content-Disposition: inline
In-Reply-To: <20020331191346.GI1954@pasky.ji.cz>
List-Id: netdev.vger.kernel.org

Dear diary, on Sun, Mar 31, 2002 at 09:13:46PM CEST, I got a letter,
where Petr Baudis <pasky@xs26.net> told me, that...
> Dear diary, on Sun, Mar 24, 2002 at 08:57:37PM CET, I got a letter,
> where Petr Baudis <pasky@xs26.net> told me, that...
> > Dear diary, on Sat, Mar 23, 2002 at 07:44:51PM CET, I got a letter,
> > where Petr Baudis <pasky@xs26.net> told me, that...
> > > I started the tcpdump there, and we'll see. However, by looking into code, we
> > > found no possibility how would zebra want to mess with loopback.
> > > 
> > > Also, we discovered that just taking down and back up any ONE interface will
> > > fix this for ALL other interfaces as well.
> > 
> > It failed again and tcpdump still runs happily. Again, taking one of the
> > interfaces down and back up (maybe it's worth mentioning that the machine acts
> > as XS26 PoP, thus it have about 270 interfaces just now up) fixed the problem
> > and the machine started to reply to neighbor solicitations again.
..snip..
> And another excellent example of the problem:
> 
> 20:47:58.981124 fe80::2a0:c9ff:fea8:c91c > fe80::3e18:401b: icmp6: neighbor sol: who has fe80::3e18:401b
> 20:47:58.981175 fe80::3e18:401b > fe80::2a0:c9ff:fea8:c91c: icmp6: redirect fe80::3e18:401b to fe80::3e18:401b

  With 2.4.19-pre5, the problem still persist :(. However, now it looks that
the replies for neighbor sol stops to be sent on per-interface basis, not all
at once, as it used to be before..

  It still looks same..

20:49:25.562585 fe80::202:55ff:fe21:4756 > ff02::5: OSPFv3-hello 40: rtrid concorde.lido-tech.net backbone [hlim 1]
20:49:27.641160 fe80::3e18:401b > fe80::202:55ff:fe21:4756: OSPFv3-dd 28: rtrid rover.dkm.cz backbone V6/E/R I/M/MS mtu 1480 S 3CBB14BE
20:49:27.991125 fe80::202:55ff:fe21:4756 > fe80::3e18:401b: OSPFv3-dd 28: rtrid concorde.lido-tech.net backbone V6/E/R I/M/MS mtu 1280 S 3CBB243F
20:49:27.991295 fe80::3e18:401b > fe80::202:55ff:fe21:4756: icmp6: redirect fe80::3e18:401b to fe80::3e18:401b
20:49:27.991318 fe80::202:55ff:fe21:4756 > fe80::3e18:401b: OSPFv3-dd 28: rtrid concorde.lido-tech.net backbone V6/E/R I/M/MS mtu 1280 S 3CBB243F
20:49:28.432548 fe80::202:55ff:fe21:4756 > fe80::3e18:401b: icmp6: neighbor sol: who has fe80::3e18:401b
20:49:28.432621 fe80::3e18:401b > fe80::202:55ff:fe21:4756: icmp6: redirect fe80::3e18:401b to fe80::3e18:401b
20:49:28.432641 fe80::202:55ff:fe21:4756 > fe80::3e18:401b: icmp6: neighbor sol: who has fe80::3e18:401b
20:49:29.431424 fe80::202:55ff:fe21:4756 > fe80::3e18:401b: icmp6: neighbor sol: who has fe80::3e18:401b
20:49:29.431512 fe80::3e18:401b > fe80::202:55ff:fe21:4756: icmp6: redirect fe80::3e18:401b to fe80::3e18:401b
20:49:29.431531 fe80::202:55ff:fe21:4756 > fe80::3e18:401b: icmp6: neighbor sol: who has fe80::3e18:401b
20:49:30.431762 fe80::202:55ff:fe21:4756 > fe80::3e18:401b: icmp6: neighbor sol: who has fe80::3e18:401b
20:49:30.431870 fe80::3e18:401b > fe80::202:55ff:fe21:4756: icmp6: redirect fe80::3e18:401b to fe80::3e18:401b
20:49:30.431890 fe80::202:55ff:fe21:4756 > fe80::3e18:401b: icmp6: neighbor sol: who has fe80::3e18:401b

  If there's any more info needed, please just tell us, we'll try to help you
as much as possible.

  Kind regards,

-- 
 
				Petr "Pasky" Baudis
 
* ELinks maintainer                * IPv6 guy (XS26 co-coordinator)
* IRCnet operator                  * FreeCiv AI hacker
.
Object orientation is in the mind, not in the compiler. -- Alan Cox
.
Public PGP key && geekcode && homepage: http://pasky.ji.cz/~pasky/
