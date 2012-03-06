From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP_STREAM performance regression on commit b3613118
Date: Tue, 06 Mar 2012 04:01:28 -0800
Message-ID: <1331035288.2474.33.camel@edumazet-laptop>
References: <1329472239.2861.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120217.133327.1178765872497293871.davem@davemloft.net>
	 <1330656317.21053.1411.camel@debian>
	 <20120301.220743.2174015405223036036.davem@davemloft.net>
	 <20120306081117.GA17375@feng-i7> <4F55CA25.2070503@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Feng Tang <feng.tang@intel.com>,
	David Miller <davem@davemloft.net>, alex.shi@intel.com,
	linux-kernel@vger.kernel.org, tim.c.chen@intel.com,
	ying.huang@intel.com, netdev@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F55CA25.2070503@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 06 mars 2012 =C3=A0 16:26 +0800, Jason Wang a =C3=A9crit :
> On 03/06/2012 04:11 PM, Feng Tang wrote:
> > On Thu, Mar 01, 2012 at 10:07:43PM -0500, David Miller wrote:
> >> >  From: Alex Shi<alex.shi@intel.com>
> >> >  Date: Fri, 02 Mar 2012 10:45:17 +0800
> >> > =20
> >>> >  >  Add CC to tang feng, He is working on this issue.
> >> > =20
> >> >  Is he?  I'm pretty sure this is due to the TCP receive window g=
rowing
> >> >  issue Eric Dumazet, Neal Cardwell and I are discussing in the t=
hread
> >> >  starting at:
> >> > =20
> >> >  http://marc.info/?l=3Dlinux-netdev&m=3D132916352815286&w=3D2
> > Yes, probably, as we did find some clue related with the tcp_r/wmem=
=2E
> >
> > Here is the regression we found:
> > On some machines, we found there is about 10% resgression of netper=
f
> > TCP-64K loopback test between 3.2 and 3.3-rc1. The exact test is:
> > ./netperf -t TCP_STREAM -l 60 -H 127.0.0.1 -i 50,3 -I 99,5 -- -s 32=
768 -S 32768 -m 4096
> >
> >
> > The test machine is a 2 socket Quad Core Core 2 Duo server(2.66GHz)=
 with
> > 8 GB RAM. Following are the debug info (ifconfig/netstat -s/tcp_rwm=
em)
> > before and after the test:
> >
> > The most obvious differences I can see are:
> > 1) 311 GB vs 241 GB from ifconfig
> > 2) the difference of the tcp_r/wmem
>=20
> Hi:
>=20
> Could you try the newest kernel? Looks like the difference has been=20
> already fixed by commit c43b874d5d714f271b80d4c3f49e05d0cbf51ed2.
>=20

Most likely yes.=20

tcp_rmem
4096    87380   87380
tcp_wmem
4096    16384   65536

Is way pessimistic :(
