From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: Bisect'ed BUG in VLAN promisc mode (6c78dcbd47)
Date: Fri, 26 Sep 2008 21:34:30 +0200
Message-ID: <1222457670.2381.8.camel@localhost.localdomain>
References: <1222437636.7598.14.camel@localhost.localdomain>
	 <48DD0A4F.6020703@trash.net>
	 <1222456933.2381.3.camel@localhost.localdomain> <48DD36D2.90103@trash.net>
	 <48DD37E3.9090706@trash.net>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:40086 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772AbYIZTec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2008 15:34:32 -0400
In-Reply-To: <48DD37E3.9090706@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-09-26 at 21:28 +0200, Patrick McHardy wrote:
> Patrick McHardy wrote:
> > Jesper Dangaard Brouer wrote:
> >> On Fri, 2008-09-26 at 18:14 +0200, Patrick McHardy wrote:
> >>> Jesper Dangaard Brouer wrote:
> >>>> Hi Patrick,
> >>>>
> >>>> Bisected me down to one of you changes
> >>>>  commit 6c78dcbd47a68a
> >>>>  [VLAN]: Fix promiscous/allmulti synchronization races
> >>>>
> >>>> Description:
> >>>> ------------
> >>>>  All other VLAN interfaces stop working, if a vlan is taken down
> >>>>  (ifconfig eth1.1025 down) _while_ there is a tcpdump running on that
> >>>>  interface.
> >>>>
> >>>>  The problem is a result of promisc mode being removed on the
> >>>>  real-device (eth1), when the vlan interface is taken down.  This
> >>>>  should not happen as other vlan devices exists that still need
> >>>>  promisc mode on the real-device (eth1).
> >>> I'm pretty sure we fixed this already in commit 0ed21b32.
> >>
> >> I think that I have tested including this commit.  The first thing I did
> >> was to test with latest DaveM net-2.6 git tree.
> > 
> > Let me see if I can reproduce it ...
> 
> Actually - one question: you're saying you're using different MAC
> addresses on the VLAN devices, so I guess thats why you're expecting
> the underlying device to still be in promiscous mode after you set
> eth1.1025 down. For devices that support multiple unicast addresses
> in hardware, we don't put the device in promiscous mode anymore.
> So the question is: is something actually not working, or did you
> just notice that the real device is no longer in promiscous mode?

It stopped working!  In the test setup I do have a machine connected to
eth1.1013, where I have a ping running, that stop working...

I use the tg3 driver for both netcards. Don't know if it supports it?

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
