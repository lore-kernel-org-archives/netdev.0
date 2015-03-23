From: Wolfgang Rosner <wrosner@tirnet.de>
Subject: Re: One way TCP bottleneck over 6 x Gbit tecl aggregated link // Kernel issue
Date: Mon, 23 Mar 2015 14:54:57 +0100
Message-ID: <201503231454.57319.wrosner@tirnet.de>
References: <201503210110.48980.wrosner@tirnet.de> <201503231005.02195.wrosner@tirnet.de> <8926B7EB-3EC1-404A-95BA-787DF248773E@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Zimmermann, Alexander" <Alexander.Zimmermann@netapp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tirnet.de ([217.7.138.221]:56348 "EHLO mail.tirnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752013AbbCWNzF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 09:55:05 -0400
In-Reply-To: <8926B7EB-3EC1-404A-95BA-787DF248773E@netapp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, 23. M=C3=A4rz 2015 10:25:33 schrieben Sie:
> Hi Wolfgang,
>
> > Am 23.03.2015 um 10:05 schrieb Wolfgang Rosner <wrosner@tirnet.de>:
> >
> > Am Montag, 23. M=C3=A4rz 2015 03:33:17 schrieb Eric Dumazet:
> >> On Mon, 2015-03-23 at 01:57 +0100, Wolfgang Rosner wrote:
> >>> Are you ready to assist me on this track?
> >>
> >> First check if the problem is already solved, using this git tree =
?
> >>
> >> http://git.kernel.org/cgit/linux/kernel/git/davem/net.git
> >
> > Is it OK to use this 3.19 tag?
> > https://kernel.googlesource.com/pub/scm/linux/kernel/git/davem/net.=
git/+/
> >v3.19
> >
> >
> > I see that head is v4.0-rc4
> > I'm afraid that this might break other things.
> > I think of aufs, which I need to get my clients nfsroot booted.
>
> probably you can take a look on OverlayFS (instead of aufs) which
> was introduced in kernel 3.18
>
> Alex


Hi Alex,

Thank you for the tip.
But if it just were that easy as to have a look at it....

As far as I know, overlayfs only allows two layers, right?
So for more complex trees, I could maybe stack them (so I hope).

To do so, at least I had to redesign my complete script which builds th=
e=20
nfsroot mimics as shown below.

And as far as I could figure out, the representation of whiteouts is di=
fferent=20
in aufs and in overlayfs. So I cannnot simply use my existing aufs bran=
ches=20
and stack them by overlayfs, without breaking the file/ whiteout consis=
tency,=20
or can I?


However, when making the decision in favour of aufs, the udba ("user di=
rect=20
branch access") feature (and lack thereof in overlayfs) was the main re=
ason=20
not to go for overlayfs:

> Changes to the underlying filesystems while part of a mounted overlay
> filesystem are not allowed.  If the underlying filesystem is changed,
> the behavior of the overlay is undefined,
( from https://www.kernel.org/doc/Documentation/filesystems/overlayfs.t=
xt )

Is this going to change in the foreseeable future?
Are you aware of any plans to implement UDBA in overlayfs?
If so, I would be glad to participate in testing.

I could live without the udba feature for a limited test period.
But I got used to the possibility to install packages in a package laye=
r, fine=20
tune configuration in another layer and live test this on a parallel cl=
uster=20
of 16 machines, without dropping off nfsroot each time.

Maybe, part of this funcitonality can be replaced by btrfs snapshotting=
=2E
But nevertheless, it would end up as a comlepte redesign of my cluster =
setup.


Wolfgang Rosner



#######################################################################=
#####

This is how my aufs mounts look like:

aufs-nfsroot-blade-001 on /cluster/nfs/nfsr/blade-001.crunchnet type au=
fs=20
(rw,relatime,si=3D88a4f4d462df4343)
        0 rw id=3D64 path=3D/cluster/node_roots/wheezy-HD-2015_02_21/co=
w/cow_001
        1 ro+wh id=3D65 path=3D/cluster/node_roots/wheezy-HD-2015_02_21=
/config
        2 ro+wh id=3D66 path=3D/cluster/node_roots/wheezy-HD-2015_02_21=
/mask
        3 ro+wh id=3D67 path=3D/cluster/node_roots/wheezy-HD-2015_02_21=
/pkg_std
        4 ro id=3D68 path=3D/cluster/node_roots/wheezy-HD-2015_02_21/ba=
se
        xino: /tmp/.aufs.xino
	:
	(repeated 16 times)
	:
aufs-nfsroot-blade-016



plus 3 admin layers (writable for each intermediary layer)



root@cruncher:/cluster/etc/scripts/available# mount | grep aufs
aufs-nfsroot-blade-001 on /cluster/nfs/nfsr/blade-001.crunchnet type au=
fs=20
(rw,relatime,si=3D88a4f4d462df4343)
aufs-nfsroot-blade-002 on /cluster/nfs/nfsr/blade-002.crunchnet type au=
fs=20
(rw,relatime,si=3D88a4f4d3fe245343)
aufs-nfsroot-blade-003 on /cluster/nfs/nfsr/blade-003.crunchnet type au=
fs=20
(rw,relatime,si=3D88a4f4d3fe9c5343)
aufs-nfsroot-blade-004 on /cluster/nfs/nfsr/blade-004.crunchnet type au=
fs=20
(rw,relatime,si=3D88a4f4d467b53343)
aufs-nfsroot-blade-005 on /cluster/nfs/nfsr/blade-005.crunchnet type au=
fs=20
(rw,relatime,si=3D88a4f4d47db69343)
aufs-nfsroot-blade-006 on /cluster/nfs/nfsr/blade-006.crunchnet type au=
fs=20
(rw,relatime,si=3D88a4f4d4630bb343)
aufs-nfsroot-blade-007 on /cluster/nfs/nfsr/blade-007.crunchnet type au=
fs=20
(rw,relatime,si=3D88a4f4d4586cc343)
aufs-nfsroot-blade-008 on /cluster/nfs/nfsr/blade-008.crunchnet type au=
fs=20
(rw,relatime,si=3D88a4f4d458689343)
aufs-nfsroot-blade-009 on /cluster/nfs/nfsr/blade-009.crunchnet type au=
fs=20
(rw,relatime,si=3D88a4f4d3fda97343)
aufs-nfsroot-blade-010 on /cluster/nfs/nfsr/blade-010.crunchnet type au=
fs=20
(rw,relatime,si=3D88a4f4d3fe3be343)
aufs-nfsroot-blade-011 on /cluster/nfs/nfsr/blade-011.crunchnet type au=
fs=20
(rw,relatime,si=3D88a4f4d3fe8cb343)
aufs-nfsroot-blade-012 on /cluster/nfs/nfsr/blade-012.crunchnet type au=
fs=20
(rw,relatime,si=3D88a4f4d3fc90c343)
aufs-nfsroot-blade-013 on /cluster/nfs/nfsr/blade-013.crunchnet type au=
fs=20
(rw,relatime,si=3D88a4f4d4622fb343)
aufs-nfsroot-blade-014 on /cluster/nfs/nfsr/blade-014.crunchnet type au=
fs=20
(rw,relatime,si=3D88a4f4d3e2cc8343)
aufs-nfsroot-blade-015 on /cluster/nfs/nfsr/blade-015.crunchnet type au=
fs=20
(rw,relatime,si=3D88a4f4d0ca64e343)
aufs-nfsroot-blade-016 on /cluster/nfs/nfsr/blade-016.crunchnet type au=
fs=20
(rw,relatime,si=3D88a4f4d0ca92e343)
aufs_pkg_std on /cluster/node_roots/wheezy-HD-2015_02_21/admount-pkg_st=
d type=20
aufs (rw,relatime,si=3D88a4f4d46dced343)
aufs_mask on /cluster/node_roots/wheezy-HD-2015_02_21/admount-mask type=
 aufs=20
(rw,relatime,si=3D88a4f4d3b0a2b343)
aufs_config on /cluster/node_roots/wheezy-HD-2015_02_21/admount-config =
type=20
aufs (rw,relatime,si=3D88a4f4d3fee4c343)
