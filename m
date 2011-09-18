From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: [GIT] Networking
Date: Sun, 18 Sep 2011 21:23:33 +0200
Message-ID: <20110918192333.GA1641@x4.trippels.de>
References: <20110918.022125.1554085675403900813.davem@davemloft.net>
 <CA+55aFxc1tMCXKBV33PVD5BybTLBpfJAEcObvoQwbwqbKOsp7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFxc1tMCXKBV33PVD5BybTLBpfJAEcObvoQwbwqbKOsp7g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2011.09.18 at 11:06 -0700, Linus Torvalds wrote:
> 2011/9/17 David Miller <davem@davemloft.net>:
> >
> > dpward (2):
> > =A0 =A0 =A0net: Make flow cache namespace-aware
> > =A0 =A0 =A0net: Handle different key sizes between address families=
 in flow cache
> >
> > nhorman (1):
> > =A0 =A0 =A0net: don't clear IFF_XMIT_DST_RELEASE in ether_setup
> >
> > rajan.aggarwal85@gmail.com (1):
> > =A0 =A0 =A0net/can/af_can.c: Change del_timer to del_timer_sync
>=20
> Guys, if somebody has such a broken email setup that they don't even
> show their own name, don't take patches from them.
>=20
> If you cannot even set up email sanely, there is zero reason to
> believe that the patch should be good. And if the patch is trivial an=
d
> you want to take it despite the source of the patch being crap, pleas=
e
> spend the five seconds to fix it up.
>=20
> Proper names are part of the commit message. Don't make it look like
> crap. I get ugly flashbacks to SVN or CVS when I see stuff like this.
> Don't do it.

Plus commit 946cedccbd73874 breaks the build:

  LD      init/built-in.o
  LD      .tmp_vmlinux1
net/built-in.o:sysctl_net.c:function tcp_v4_conn_request: error: undefi=
ned reference to 'cookie_v4_init_sequence'
make: *** [.tmp_vmlinux1] Error 1

commit 946cedccbd7387488d2cee5da92cdfeb28d2e670
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Tue Aug 30 03:21:44 2011 +0000

    tcp: Change possible SYN flooding messages

    "Possible SYN flooding on port xxxx " messages can fill logs on ser=
vers.

    Change logic to log the message only once per listener, and add two=
 new
    SNMP counters to track :

    TCPReqQFullDoCookies : number of times a SYNCOOKIE was replied to c=
lient

    TCPReqQFullDrop : number of times a SYN request was dropped because
    syncookies were not enabled.

    Based on a prior patch from Tom Herbert, and suggestions from David=
=2E


--=20
Markus
