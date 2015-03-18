From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCH net-next 2/4] ipv4: Correct two conditions checking when
 buildig nskb
Date: Wed, 18 Mar 2015 08:44:08 -0400
Message-ID: <CABrhC0mYu0GVvtvzX_yLwF=_ZQ9eeLKqsqcCKs3MPC1Mb8GY8w@mail.gmail.com>
References: <1425978986-8512-1-git-send-email-fan.du@intel.com>
	<1425978986-8512-3-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Fan Du <fengyuleidian0615@gmail.com>
To: Fan Du <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:35317 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932949AbbCRMoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 08:44:10 -0400
Received: by labjg1 with SMTP id jg1so34854503lab.2
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2015 05:44:08 -0700 (PDT)
In-Reply-To: <1425978986-8512-3-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2015 at 5:16 AM, Fan Du <fan.du@intel.com> wrote:
> When traversing write queue to build 'nskb', the size of 'copy'
> could only be equal or smaller than skb->len.
>
> And as we need exactly 'probe_size' bytes data for 'nskb', thus
> break condition could only be len == probe_size.
>
> Signed-off-by: Fan Du <fan.du@intel.com>
> ---
>  net/ipv4/tcp_output.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 5a73ad5..79977d1 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1954,7 +1954,7 @@ static int tcp_mtu_probe(struct sock *sk)
>                                                             skb_put(nskb, copy),
>                                                             copy, nskb->csum);
>
> -               if (skb->len <= copy) {
> +               if (skb->len == copy) {
>                         /* We've eaten all the data from this skb.
>                          * Throw it away. */
>                         TCP_SKB_CB(nskb)->tcp_flags |= TCP_SKB_CB(skb)->tcp_flags;
> @@ -1977,7 +1977,7 @@ static int tcp_mtu_probe(struct sock *sk)
>
>                 len += copy;
>
> -               if (len >= probe_size)
> +               if (len == probe_size)
>                         break;
>         }
>         tcp_init_tso_segs(sk, nskb, nskb->len);
> --
> 1.7.1
>

This is called "defensive programming." ;-)
