From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] netem: add cell concept to simulate special MAC behavior
Date: Sun, 11 Dec 2011 00:58:22 +0100
Message-ID: <20111210235822.GM17840@Chamillionaire.breakpoint.cc>
References: <1323535432.4016.24.camel@edumazet-laptop>
 <1323560203-11715-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	shemminger@vyatta.com, Florian Westphal <fw@strlen.de>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:40715 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751360Ab1LJX6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2011 18:58:23 -0500
Content-Disposition: inline
In-Reply-To: <1323560203-11715-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hagen Paul Pfeifer <hagen@jauu.net> wrote:
> +static psched_time_t packet_len_2_sched_time(unsigned int len, struct netem_sched_data *q)
>  {
[..]
> +	if (q->cell_size) {
> +		u32 cells = reciprocal_divide(len, q->cell_size_reciprocal);
> +		u32 mod_carry = len - cells * q->cell_size;
> +
> +		if (mod_carry)
> +			mod_carry = (len > q->cell_size || !cells) ?
> +				q->cell_size - mod_carry : len - mod_carry;
> +
> +		if (q->cell_overhead) {
> +			if (mod_carry)
> +				++cells;
> +			len += cells * q->cell_overhead;
> +		}
> +
> +		len += mod_carry;

Why did you chose to replace the previous version?

if (q->cell_size) {
      u32 cells = reciprocal_divide(len, q->cell_size_reciprocal);

      if (len > cells * q->cell_size)  /* extra cell needed for remainder */
                        cells++;
      len = cells * (q->cell_size + q->cell_overhead);
}

I think that it is a lot easier to read -- did you find a problem with it?
