From: Willy Gardiol <willy@gardiol.org>
Subject: Re: The 8169 driver: issue with cross cable
Date: Sun, 20 Feb 2005 17:12:46 +0100
Message-ID: <200502201712.49589.willy@gardiol.org>
References: <200502192011.25428.willy@gardiol.org> <20050219205055.GA2793@electric-eye.fr.zoreil.com>
Reply-To: willy@gardiol.org
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1610967.7YtWMaESEO";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050219205055.GA2793@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1610967.7YtWMaESEO
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline


Problem: r8169 hosed sporadically using a cross-cable.

Configuration:
=2D server side: x86 box with r8169 on a Hamlet PCI card, file server NFS.=
=20
=2D client side: x86 box with r8169 inegrated on a nForce2 motherboard. NFS=
=2Droot=20
on the server (no local hard drives, four NFS mounts)
=2D connection: cross cable UTP CAT5

(Alternative configuration:
=2D RTL-8139 (8139too module) PCI card on both boxes. With this configurati=
on=20
(same kernel, same files, same cable) everything works great.)

The problem is present with any kernel versions up to 2.6.10 (tried many=20
different kernels).

Step to reproduce the problem: grab a few CDs with grip (tested with ATAPI=
=20
cdrw without scsi emulation).=20

Syntomps: one of the mounts will be hosed while the others will work. After=
=20
some time either the nfs activity hangs on all mounts or the hosed mount wi=
ll=20
un-hose. Tipically it will hose again soon.

I am now doing tests using kernel 2.6.11-r4 with Francois's patch.

I did two tests, one at 1000mbit/sec and one at 100mbit/sec limiting the sp=
eed=20
using ethtool.

The problem persist in both tests. I launch grip and start grabbing a CD,=20
after the first track is read from che CD the process hangs. Then i start a=
=20
second grip and start again ripping the same CD, this time the entire nfs=20
mount hangs.

Per each test i reported some general data:
Output of "lspci -vx" posted to:  spci-vx.txt
Output of "lsmod" posted to: modules.txt
Output of boot posted to:dmesg.txt
Output of ethtool on r8169 (and rtl-8139): ethtool.txt

And specific data:
Output ifconfig and interrupts immediately after boot:=20
interrupts-ifconfig-boot.txt
After some activity (login/startx/launch konsole, a few pings, and launch o=
f=20
grip):
interrupts-ifconfig-initial.txt
When the program grip is hosed:
interrupts-ifconfig-hosed.txt
When mount point /deposito is hosed:
interrupts-ifconfig-hosed2.txt

(note: grip works on /deposito)


I bzip2ed all this files into two archives, one per each test (one couple p=
er=20
server and one per client)

You can get them at:
http://www.gardiol.org/r8169/1000-client.tar.bz2
http://www.gardiol.org/r8169/1000-server.tar.bz2
http://www.gardiol.org/r8169/100-client.tar.bz2
http://www.gardiol.org/r8169/100-server.tar.bz2

At the beginning of each file i wrote the output of "uname -a".

I am available for any more data.
bye and thanks.

ps: i am not subscribed to the list please keep me in CC.

Alle Saturday 19 February 2005 21:50, hai scritto:
> Willy Gardiol <willy@gardiol.org> :
> [...]
>
> > i am sorry to bother you directly.
>
> No problem but it would be nice to Cc: netdev@oss.sgi.com.
>
> [...]
>
> > I have a fileserver and a remote client which both have a r8169 based
> > card. The server has a Hamlet card and the client has the gigabit chip
> > integrated.
>
> An 'lspci -vx' would be welcome. So will a complete dmesg from boot.
>
> > The two machines are linked with a cross cable about 20mt long, UTP CAT=
5.
>
> Which link settings does the r8169 negociate ('ethtool ethX') ?
>
> [...]
>
> > During one of these locks i can, as usual, access the other nfs mounts.
>
> Ok. So the card is not hosed.
>
> > I tried to:
> > - move PCI cards to avoid conflicts
> > - upgraded to latest stable kernel 2.6.10
> > - removed any binary only driver
> > - changed the server mounts and filesystems (ext3/reiserfs)
> >
> > Also, the problem is still present if i use one r8169 based and one
> > rtl-8139 100mbit card.
>
> Do you notice packet loss/errors or such on the 8169 side ? Typically, how
> does 'ifconfig' output like when a mount point is hosed ?
>
> > When i remove BOTH r8169 and use 100mbit only cards (two 8139 based pci
> > cards) i do not suffer from these hangs.
>
> Which kind of 8139 driver: 8139too or 8139cp ?
>
> > What can i do to solve this problem, or help you on the subject?
>
> It will need some debugging. It is not clear if the r8169 is the issue or
> if simply triggers the problem. Suggestions:
> - use 2.6.10-rc4 + attached patch;
> - avoid binary modules as I don't support them;
> - if r8169 negociates 1000Mbps, use ethtool to limit it at 100Mbps;
> - save the content of /proc/interrupts and ifconfig output at regular
>   interval (say, at boot, after some ping -q -f -l 16 a.b.c.d and once
>   a mountpoint is hung);
> - avoid gcc 2.95.x;
> - when a mountpoint is hung, issue 'echo t > /proc/sysrq-trigger' and save
>   the kernel output. This assumes CONFIG_MAGIC_SYSRQ=3Dy at build time and
>   kernel.sysrq =3D 1 in /etc/sysctl.conf.
>
> If you have a straight cable, two 8169 should be able to do the crossing
> themselves.
>
> --
> Ueimor

=2D-=20

!=20
 Willy Gardiol - willy@gardiol.org
 www.gardiol.org
 +39 3492800983
 Use linux for MY freedom.=20
 Your freedom may come as a side effect.

    "Era un mondo adulto,
     si sbagliava da professionisti"

      Paolo Conte, Boogie


--nextPart1610967.7YtWMaESEO
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCGLcBvgbSPju7wvkRAqpIAKCV6KPYZgyO91suma91C7XKE8wIFwCeOgv9
09I/PoLoAuAZoD5zKOt1V+I=
=8jOo
-----END PGP SIGNATURE-----

--nextPart1610967.7YtWMaESEO--
