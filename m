From: Glauber Costa <glommer@parallels.com>
Subject: Re: [v3.3-rc1 regression] TCP: too many of orphaned sockets
Date: Fri, 27 Jan 2012 16:49:32 +0400
Message-ID: <4F229D5C.4040300@parallels.com>
References: <20120127124641.GA30819@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120127124641.GA30819@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/27/2012 04:46 PM, Ingo Molnar wrote:
>
> There's a new TCP regression in latest -git that triggers in
> randconfig testing.
>
> With the attached config i'm getting tons of these messages:
>
> [   32.751209] TCP: too many of orphaned sockets
> [   37.198307] TCP: too many of orphaned sockets
> [   42.464404] TCP: too many of orphaned sockets
> [   48.920392] TCP: too many of orphaned sockets
> [   56.370026] TCP: too many of orphaned sockets
> [   64.605937] TCP: too many of orphaned sockets
>
> and it's not possible to ssh into the testbox, the TCP
> connection hangs.
>
> Before i put more effort into debugging this, is this bug
> already known/fixed?
>
> NOTE: the .config is randconfig generated so it might have a few
> weird combinations of config options. One such thing i noticed
> is !CONFIG_BUG, this produces at least one of the following
> build warnings in the networking code:
>
> net/core/ethtool.c:211:1: warning: control reaches end of non-void fu=
nction [-Wreturn-type]
> net/core/dev.c:1892:33: warning: unused variable =91null_features=92 =
[-Wunused-variable]
> net/packet/af_packet.c:1878:30: warning: =91hdrlen=92 may be used uni=
nitialized in this function [-Wmaybe-uninitialized]
> net/xfrm/xfrm_policy.c:2456:17: warning: =91xfrm_dst_ops=92 may be us=
ed uninitialized in this function [-Wmaybe-uninitialized]
> net/xfrm/xfrm_policy.c:1351:7: warning: =91dst_ops=92 may be used uni=
nitialized in this function [-Wmaybe-uninitialized]
> net/xfrm/xfrm_policy.c:1333:18: note: =91dst_ops=92 was declared here
> net/xfrm/xfrm_policy.c:1351:7: warning: =91dst_ops=92 may be used uni=
nitialized in this function [-Wmaybe-uninitialized]
> net/xfrm/xfrm_policy.c:1333:18: note: =91dst_ops=92 was declared here
>
> Note#2, the message should probably be fixed as well:
>
>   -   TCP: too many of orphaned sockets
>   +   TCP: too many orphaned sockets
>
> Thanks,
>
> 	Ingo

Ingo,
mind sharing your config?

I haven't seen this, but I intend to run this against my recent=20
patchseries and at least see if this is the culprit.

Thanks.
