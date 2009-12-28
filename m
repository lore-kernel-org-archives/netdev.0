From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] tcp: for tcp westwood implementation
Date: Mon, 28 Dec 2009 08:43:14 +0000
Message-ID: <20091228084313.GA7302@ff.dom.local>
References: <39ba5b880912272235k3f9c4892gf02a727c8ddfc551@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jae-Hyun Hwang <jhhwang@os.korea.ac.kr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:53627 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbZL1InV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 03:43:21 -0500
Received: by fxm25 with SMTP id 25so4414788fxm.21
        for <netdev@vger.kernel.org>; Mon, 28 Dec 2009 00:43:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <39ba5b880912272235k3f9c4892gf02a727c8ddfc551@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28-12-2009 07:35, Jae-Hyun Hwang wrote:
> I'm sorry about posting such a damaged email.
> I resubmit the patch by plain-text.

Most probably it's still wrong (e.g. no tabs).
http://marc.info/?l=linux-netdev&m=126198215600946&q=raw

Did you try to send it to yourself?

Jarek P.

> 
> From: Jae-Hyun Hwang <jhhwang@os.korea.ac.kr>
> 
> Current net/ipv4/tcp_westwood.c seems to be unnatural when compared
> with Westwood papers.
> Since Linux TCP calls '.ssthresh' interface whenever packet loss is
> detected, it is more natural that the interface points to
> 'tcp_westwood_bw_rttmin' function, not Reno's function.
> This patch also enables Westwood to perform its algorithm when
> CA_EVENT_LOSS event is generated as explained in the papers.
> 
> Signed-off-by: Jae-Hyun Hwang <jhhwang@os.korea.ac.kr>
> ---
> 
> --- linux-2.6.32.2/net/ipv4/tcp_westwood.c.orig 2009-12-28
> 13:35:42.000000000 +0900
> +++ linux-2.6.32.2/net/ipv4/tcp_westwood.c      2009-12-28
> 13:36:54.000000000 +0900
> @@ -232,12 +232,7 @@ static void tcp_westwood_event(struct so
>                 westwood_fast_bw(sk);
>                 break;
> 
> -       case CA_EVENT_COMPLETE_CWR:
> -               tp->snd_cwnd = tp->snd_ssthresh = tcp_westwood_bw_rttmin(sk);
> -               break;
> -
>         case CA_EVENT_FRTO:
> -               tp->snd_ssthresh = tcp_westwood_bw_rttmin(sk);
>                 /* Update RTT_min when next ack arrives */
>                 w->reset_rtt_min = 1;
>                 break;
> @@ -274,9 +269,8 @@ static void tcp_westwood_info(struct soc
> 
>  static struct tcp_congestion_ops tcp_westwood = {
>         .init           = tcp_westwood_init,
> -       .ssthresh       = tcp_reno_ssthresh,
> +       .ssthresh       = tcp_westwood_bw_rttmin,
>         .cong_avoid     = tcp_reno_cong_avoid,
> -       .min_cwnd       = tcp_westwood_bw_rttmin,
>         .cwnd_event     = tcp_westwood_event,
>         .get_info       = tcp_westwood_info,
>         .pkts_acked     = tcp_westwood_pkts_acked,
> --
> 
> On Mon, Dec 28, 2009 at 2:56 PM, David Miller <davem@davemloft.net> wrote:
> - Hide quoted text -
>> Annyoung-haseyo,
>>
>> Your patch was damaged by your email client (long lines
>> were chopped up with newlines, etc.), as such it is not
>> usable.
>>
>> Please fix this up and resubmit your patch.
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 



