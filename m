From: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Thu, 20 Aug 2009 22:37:43 +0200
Message-ID: <200908202237.43776.rene.mayrhofer@gibraltar.at>
References: <4A65EC3F.4050400@gibraltar.at> <392fb48f0908191505v47f99d1cvef18d40bcf4c08d1@mail.gmail.com> <20090819174629.649f837f@nehalam>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_XQbjK5SHD0OvPeI"
Cc: Mike McCormack <mikem@ring3k.org>, netdev@vger.kernel.org,
	Richard Leitner <leitner@esys.at>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter1.gibraltar.at ([80.120.3.98]:52054 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbZHTUhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 16:37:51 -0400
In-Reply-To: <20090819174629.649f837f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_XQbjK5SHD0OvPeI
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit

Hi Stephen,

Am Donnerstag, 20. August 2009 02:46:29 schrieb Stephen Hemminger:
> On Thu, 20 Aug 2009 07:05:03 +0900
>
> Mike McCormack <mikem@ring3k.org> wrote:
> > 2009/8/20 Rene Mayrhofer <rene.mayrhofer@gibraltar.at>:
> > > Pulling the latest sky2.c and sky2.h from net-next-2.6 and applying the
> > > patch rids me of the oops - it is unreproducible right now. However, a
> > > networking restart (i.e. all interfaces attached to sky2) leaves the
> > > devices in a state where they no longer receive any network packets (at
> > > least nothing visible in tcpdump). In this state, rmmod sky2 / modprobe
> > > sky2 gives:
> >
> > After you've got it into that state, does "rmmod sky2; modprobe sky2"
> > change anything?

Nope, tried it multiple times.


I've also tried the net-next-2.6 version of sky2.[ch] as of yesterday without 
Mike's "bandaid" patches. With that version (the last one in branch 
gibraltar-3.0 at https://www.gibraltar.at/git/linux-2.6-gibraltar.git), I 
managed to successfully do a networking restart (with "light" traffic on one 
interface), leaving the interfaces functional after the restart. This worked 
even twice in a row, so mabye we are onto something here. This is certainly an 
improvement over the version with Mike's last patch (from yesterday) applied, 
which left the interfaces broken after a restart (and with the quoted errors 
on a rmmod/modprobe sky2). 

However, after doing a ping -f on one of the (GBit) interfaces to another host 
on the same switch for a few seconds and then executing networking restart, 
the result was an immediate reboot of the box without any oops being printed 
to the (serial) console beforehand. 

The same thing happened without particularly heavy traffic after executing 
networking restart twice and then just letting the box sit idle (with some 
traffic on the interfaces) for a few minutes.

> Please send (I forget) the hardware info (lspci) and the register values
> from ethtool -d ethX.

Attached (lspci -v).

> Some part of the power control doesn't work on Rene's system, so
> device falls off the bus. Probably no auxilary +5 supplied, the register
> values will tell whether driver is at fault (turning on aux when not
> available), or hardware is lying about vaux.

Is it possible to disable (kernel-level) power control for particular PCI 
devices to check if this is indeed the issue? Or do you suspect hardware-level 
power-off when the chip state goes down?

best regards,
Rene

-- 
-------------------------------------------------
Gibraltar firewall       http://www.gibraltar.at/

--Boundary-00=_XQbjK5SHD0OvPeI
Content-Type: application/x-gzip;
  name="lspci.out.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="lspci.out.gz"

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
gSoAAA==

--Boundary-00=_XQbjK5SHD0OvPeI
Content-Type: application/x-gzip;
  name="ethtool.out.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="ethtool.out.gz"

H4sICDiyjUoCA2V0aHRvb2wub3V0AMVYWXPiOBB+jn5FPyYPU5HkA3vezJVhl0xYQmZ2Hh0jgitg
sz5y/Ptp+QABMnh2NzUuV8pIn1rd6q8PhUx6IwjiaBE+kU/bh1D6GfxHYAxsDqYBtAPUBEaBUmCu
/CtfDtSpvylhuAZB+MPgMKfbieJlEByMFGu4XEPPv6YjdTHxwyDGwRrTaVj2KLct9zG3axa0GnUo
+OU3A6swZiHkOC+NNIgl1xhgBRVaNWbv2wKBAEPuY8s1ARhUDpXytm+ABjDNGXQq3cxWJ1GuIb04
ypJ4BVPxFKaZSFLFe7UT6znwgkCkKUziJAP1oW8oajzoQyXt+j7zszwFOEB5NjWYbXpkFKG4JN9k
cB/nSSAAjrC0ehTsrZ8+A2iwvQLJ+gr2i5/MX/1EwCBJ4mS7jVbuAbbehr7xAaXG0Bgq2Pq8Wukb
z0XiZ2Ec7amuYLc7N0BVrAKZhWuRkItRFGYKAr75q1yoSy5mIi0QvBJXay+HyI2IUOAKJnmyiVM8
nNH1nc4ojw4I6aI7b/3IfxJrEWXwgFsfMwW50rufIpcCEb4I+CsXqA/TnBQr1JPY+/co0AML7LB6
CqyXngArZpNbrwfefJ4gWcURoYmc2V+PZ+diOHSBumBZYFolhrfAGAcYTXxFIsiQVtn7RhzpbHpw
+ccVmdz2dfM1ymBwyRD15ccplIMnugw3MJpDA6Jrw4/8OY4+cRj04DIRL8CvyNRfQzdfLDDAdYto
j5AqnieJWIgsWBJ9FBQu4JxTj4x9JN4omos3FcCp2ZGyMH1U7tG4z7AdP5BunP3NIBGbg2TDbQtn
uGZGroBsiWKX8Uo5A0bJJNdoAy5zCKnJylpZJ81rso5RbrSwzi1JeiN0KhlOk7IWmkFmiR+la4z6
/66txVgbV7hOs7LSFXpl5UxNmuFoeEcuvidhJrByhDI77iuKKl5MhT/XzVbTY/EiVnpOyzT33cdl
az95Pp7GU7sYYe7QQorpSs2V3GIvpxq0b+7lVDmwy6mmLqciA9NCniqJDRzsLRRJxcAZSaj0foZ3
e/vayIEzMsiNzISBhiBShGWTG5lSmuZRwHj09c+m+Vo8I9pqv0N2KDMbWLrzgyMDvmZ3A0YysQ7X
BsyAqnIWq/j1UP2ypuwwGz/x12KfdvSt38HDvRdJiPVxjYVXtxfnbEDKH1V74ZeR9FlXLSRssnxP
wwBFngKS6RtUBzuI5kfRqS16nSHxVusYqTDMVyuYFUmwCUtrZ1wX5GmQ68rs4XhEhi8MVznK0/df
pVzmdLoqdnach9XU0kUH5FFQtTOnsKzjkYfNBv0z8XPsUrRgpfiP49d2WIeRb2PvK8z8JwA4fb6W
U9rWmMX2dVCw+sx1iG1Mf03YhoSo6EtmH0sj1o5GrGoIWtJoZ2YrGtHWNJLY304j/gs02seeohEz
8JL5ITTiSn9Utd1H3XTVOQaN+R2FWUNKuu9oRi/OdboVj+ma1CF9kQZJuJENs56ySndi2l3L4fR0
/anXuB156yDy6oQVer055yvEdm8fzt1oJc5mnkf6cSQAzuhQ1K9/8qZwabKvl+br6r5yt1ik2IvZ
lmVY6Ok0LJgPssAiiJ8DkeK6ta199VXqch6m/uNKzK8IKS9Zh5B/5XY88zZutwz7F93OsCvl7dxe
p4lWbmdt3S6bYvZxbkf7XLfwKJQtupzljvRlga2SAt1F59S7fSw9cuwqfZevP6e2pWKApeJUFlOx
FlajU5npEFum6W3SvS6T8MQPnkWWKti+U6fp81jDo0dyv4RPS7xGhTHa8a7+v2NwLLcJ2zHxvlbs
doLkallpushosCdbZvW+zbzDwFbocCq4/w/WDJzWrGGdYWvWMJu3Zk2B/e1ewHvqTynJwdIFFwAA

--Boundary-00=_XQbjK5SHD0OvPeI--
