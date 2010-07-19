From: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>
Subject: Re: oops in tcp_xmit_retransmit_queue() w/ v2.6.32.15
Date: Mon, 19 Jul 2010 10:06:09 +0200
Message-ID: <4C440771.7080107@nets.rwth-aachen.de>
References: <4C358AAA.9080400@kernel.org> <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi> <4C3EF7EA.2040900@nets.rwth-aachen.de> <1279195528.2496.2.camel@edumazet-laptop> <4C3F053F.7090704@nets.rwth-aachen.de> <alpine.DEB.2.00.1007161448330.13946@melkinpaasi.cs.helsinki.fi> <4C404FC5.6040107@nets.rwth-aachen.de> <alpine.DEB.2.00.1007161602510.13946@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tejun Heo <tj@kernel.org>, lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fehrmann, Henning" <henning.fehrmann@aei.mpg.de>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1007161602510.13946@melkinpaasi.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I ran tests for about 2 hours with this patch and I got no output from=20
the debug patch. This seems to have solved at least my problem :)

Thanks!
> [PATCH] tcp: fix crash in tcp_xmit_retransmit_queue
>
> It can happen that there are no packets in queue while calling
> tcp_xmit_retransmit_queue(). tcp_write_queue_head() then returns
> NULL and that gets deref'ed to get sacked into a local var.
>
> There is no work to do if no packets are outstanding so we just
> exit early.
>
> There may still be another bug affecting this same function.
>
> Signed-off-by: Ilpo J=E4rvinen<ilpo.jarvinen@helsinki.fi>
> Reported-by: Lennart Schulte<lennart.schulte@nets.rwth-aachen.de>
> ---
>   net/ipv4/tcp_output.c |    3 +++
>   1 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index b4ed957..7ed9dc1 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2208,6 +2208,9 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
>   	int mib_idx;
>   	int fwd_rexmitting =3D 0;
>
> +	if (!tp->packets_out)
> +		return;
> +
>   	if (!tp->lost_out)
>   		tp->retransmit_high =3D tp->snd_una;
>
>   =20
