From: "David S. Miller" <davem@davemloft.net>
Subject: Re: tun.c patch to fix "smp_processor_id() in preemptible code"
Date: Tue, 19 Oct 2004 15:33:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019153308.488d34c1.davem@davemloft.net>
References: <E1CK1e6-0004F3-00@gondolin.me.apana.org.au>
	<1098222676.23367.18.camel@krustophenia.net>
	<20041019215401.GA16427@gondor.apana.org.au>
	<1098223857.23367.35.camel@krustophenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, vda@port.imtp.ilyichevsk.odessa.ua,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org, maxk@qualcomm.com,
        irda-users@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Lee Revell <rlrevell@joe-job.com>
In-Reply-To: <1098223857.23367.35.camel@krustophenia.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Oct 2004 18:10:58 -0400
Lee Revell <rlrevell@joe-job.com> wrote:

>   /*
>    * Since receiving is always initiated from a tasklet (in iucv.c),
>    * we must use netif_rx_ni() instead of netif_rx()
>    */
> 
> This implies that the author thought it was a matter of correctness to
> use netif_rx_ni vs. netif_rx.  But it looks like the only difference is
> that the former sacrifices preempt-safety for performance.

You can't really delete netif_rx_ni(), so if there is a preemptability
issue, just add the necessary preemption protection around the softirq
checks.
