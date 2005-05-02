From: Bruno <bonbons67@internet.lu>
Subject: Re: [Bugme-new] [Bug 4566] New: B44 Randomly driver starts sending garbage and stops receiving
Date: Mon, 2 May 2005 21:56:52 +0200
Message-ID: <200505022156.52634.bonbons67@internet.lu>
References: <20050430142334.4fa8745d.akpm@osdl.org> <20050430222841.GA9172@xi.wantstofly.org>
Reply-To: bonbons67@internet.lu
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050430222841.GA9172@xi.wantstofly.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sunday 01 May 2005 00:28, Lennert Buytenhek wrote:
> On Sat, Apr 30, 2005 at 02:23:34PM -0700, Andrew Morton wrote:
> > get following output (repeating at a high rate):
> > 22:33:01.018523 00:40:05:43:5e:fe > 01:80:c2:00:00:01, ethertype Unkn=
own
> > (0x8808), length 60:
> >     0x0000: 0001 ffff 0000 0000 0000 0000 0000 0000
> >     0x0010: 0000 0000 0000 0000 0000 0000 0000 0000
> >     0x0020: 0000 0000 0000 0000 0000 0000 0000
> > dmesg does not produce any useful output about this.
>
> Isn't that a PAUSE frame?
>
> Probably something in the b44 driver gets screwed so that it stops
> processing RX traffic, the MAC's RX FIFO then fills up, and the
> MAC (naturally) asserts flow control by periodically (in the range
> of tens to hundreds of times per second) sending PAUSE frames to
> its link partner as long as there's not enough space in its RX FIFO.
>
> These PAUSE frames should not be seen by other hosts on the LAN,
> though -- your switch should not autonegotiate flow control with
> your b44 NIC if it doesn't support it.  (Or perhaps the b44 driver
> enables flow control even though it hasn't been negotiated..)
>
>
> --L
I don't know what kind of frame that is, but it's causing quite some trou=
ble=20
on my network:
=A0- network communication is broken for all other host (Windows Hosts, A=
DSL=20
router to internet
=A0- My Linux Server can capture the traffic (it's from that one I execut=
ed=20
tcpdump, but I don't know if Linux to Linux communication is still possib=
le=20
as I never had my desktop running when it happened)
Network works correctly again once I restart the network interface (B44) =
on=20
the Laptop.

I don't know if it passes all the 2 switches on my LAN (first one for sur=
e,=20
second one I don't know as there is no box with sniffing-software behind =
it,=20
but the Windows box there does not seem to loose internet connection)

In addition the recorded MAC addresses are not addresses of my hardware. =
So=20
except thet are broadcast/multicats MAC addresses I'm wondering where the=
y do=20
come from!

If you have any suggestions on what to do for either fixing the B44 drive=
r or=20
at least making it auto-recover rapidly, this would be useful.
If there is more information that I can provide, please tell how I can fi=
nd it=20
out!
(But may take some time, as this problem does not happen every day)

Bruno
