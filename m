From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] mrp: add periodictimer to retry lost packets
Date: Wed, 18 Sep 2013 11:20:19 -0700
Message-ID: <1379528419.1787.50.camel@joe-AO722>
References: <CAB5uXS7b2CGjF=1OTzCmEeduGHSO_SOmMDv6=-bZU2VzaEQNfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Noel Burton-Krahn <noel@burton-krahn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0076.hostedemail.com ([216.40.44.76]:57044 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753334Ab3IRSUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 14:20:22 -0400
In-Reply-To: <CAB5uXS7b2CGjF=1OTzCmEeduGHSO_SOmMDv6=-bZU2VzaEQNfA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-18 at 10:09 -0700, Noel Burton-Krahn wrote:
> MRP doesn't implement the periodictimer in 802.1Q, so it never retries
> if packets get lost.  I ran into this problem when MRP sent a MVRP
> JoinIn before the interface was fully up.  The JoinIn was lost, MRP
> didn't retry, and MVRP registration failed.

Beyond the whitespace errors that make this not apply:

> diff --git a/net/802/mrp.c b/net/802/mrp.c
[]
> @@ -595,6 +600,26 @@ static void mrp_join_timer(unsigned long data)
>      mrp_join_timer_arm(app);
>  }
> 
> +static void mrp_periodic_timer_arm(struct mrp_applicant *app)
> +{
> +    unsigned long delay;
> +
> +    delay = (u64)msecs_to_jiffies(mrp_periodic_time);

Useless cast to u64

> +    mod_timer(&app->periodic_timer, jiffies + delay);

This might also be neater without the temporary

static void mrp_periodic_timer_arm(struct mrp_applicant *app)
{
	mod_timer(&app->periodic_timer,
		  jiffies + msecs_to_jiffies(mrp_periodic_timer));
}
