From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v2 net] ipv6: addrconf: fix Juniper SSL VPN client regression
Date: Tue, 12 Jul 2016 15:46:59 +0200
Message-ID: <87lh17otnw.fsf@miraculix.mork.no>
References: <1468248230-5763-1-git-send-email-bjorn@mork.no>
	<20160711.134848.216095848280988851.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Valdis.Kletnieks@vt.edu, jonas@lippuner.ca,
	hideaki.yoshifuji@miraclelinux.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:57718 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750972AbcGLNrQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 09:47:16 -0400
In-Reply-To: <20160711.134848.216095848280988851.davem@davemloft.net> (David
	Miller's message of "Mon, 11 Jul 2016 13:48:48 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> What really irks me is that we "fixing" something without knowing wha=
t
> actually is the problem.

Agreed

> Someone needs to figure out exactly what is making the Juniper thing
> unhappy.  It really shouldn't care if a link local address is assigne=
d
> to the tun device, this is fundamental ipv6 stuff.

Yes. Looks like this is up to Jonas and/or Valdis.  I tried looking for
a demo site which could be used to test the client, but could not find
any.  The product itself seems to be replaced, and it's no longer Junip=
er.
And the recommended Linux solution seems to be OpenConnect:
http://www.infradead.org/openconnect/juniper.html

Anyway, it would be good to sort out the problems with the java(?) base=
d
client.  A few proposals (not an exhaustive list - please use your
creativity):

a) Try to figure out what the traffic on the interface looks like (ther=
e
   was a single TX packet and no RX, I believe?).  Snoop on it and see
   if that is an IPv6 RS from the kernel or something the client sends.

b) Try to isolate the problem by tweaking what you can on the tun-
   interface.

     ip addr del <ipv6ll> dev tun0
     echo 1 > /proc/sys/net/ipv6/conf/tun0/disable_ipv6

  etc.  Is there anything that will make the traffic flow, or is it jus=
t
  dead?


c) Try to figure out what the client is doing.  strace it.  run lsof on
   it.  Anything unexpected?  Does it for example happen to read an
   packet from the tun file descriptor and choke?


etc,



Bj=C3=B8rn
