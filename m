From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH 0/2] [BUG FIXES - 3.10.27] sit: More backports
Date: Wed, 29 Jan 2014 12:04:05 +0100
Message-ID: <52E8E025.2060803@6wind.com>
References: <20140128205756.074448668@goodmis.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stable <stable@vger.kernel.org>,
	Clark Williams <williams@redhat.com>,
	"Luis Claudio R. Goncalves" <lclaudio@uudg.org>,
	John Kacur <jkacur@redhat.com>
To: Steven Rostedt <rostedt@goodmis.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20140128205756.074448668@goodmis.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 28/01/2014 21:57, Steven Rostedt a =C3=A9crit :
> At Red Hat we base our real-time kernel off of 3.10.27 and do lots of
> stress testing on that kernel. This has discovered some bugs that we
> can hit with the vanilla 3.10.27 kernel (no -rt patches applied).
>
> I sent out a bug fix that can cause a crash with the current 3.10.27
> when you add and then remove the sit module. That patch is obsoleted =
by
> these patches, as that patch was not enough.
Can you explain a bit more which problem remains after that patch?
I wonder if a problem remains also with ip6_tunnel.ko (net/ipv6/ip6_tun=
nel.c),
the same problem was spotted into this module.

>
> A previous patch that was backported:
>
>    Upstream commit 205983c43700ac3a81e7625273a3fa83cd2759b5
>    sit: allow to use rtnl ops on fb tunnel
>
> Had a depenency on commit 5e6700b3bf98 ("sit: add support of x-netns"=
)
> which was not backported. The dependency was only on part of that
> commit which is what I backported.
I cannot comment directly the patch, it was an attachement, hence I put=
 my
comments here.
In patch 0001-sit-Unregister-sit-devices-with-rtnl_link_ops.patch, I wo=
nder how
'if (dev_net(t->dev) !=3D net)' can be wrong. If commit 5e6700b3bf98 ("=
sit: add
support of x-netns") has not been backported, this test is always true.

>
> The other upstream commit 9434266f2c645d4fcf62a03a8e36ad8075e37943
> sit: fix use after free of fb_tunnel_dev
>
> fixes another bug we encountered, it also fixes the 3.10.27 bug
> where removing the sit module cause the crash. This is the patch
> that obsoletes my previous patch.
>
> -- Steve
>
>
> Steven Rostedt (Red Hat) (1):
>        sit: Unregister sit devices with rtnl_link_ops
>
> Willem de Bruijn (1):
>        sit: fix use after free of fb_tunnel_dev
>
> ----
>   net/ipv6/sit.c | 30 +++++++++++++++++++++++++-----
>   1 file changed, 25 insertions(+), 5 deletions(-)
>
