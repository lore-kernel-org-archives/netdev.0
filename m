From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 06/10] Make qdisc changeable.
Date: Mon, 01 Oct 2007 15:43:28 +0200
Message-ID: <4700F980.3000701@trash.net>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org> <11910199772562-git-send-email-bugfood-ml@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33146 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbXJANnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 09:43:52 -0400
In-Reply-To: <11910199772562-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corey Hickey wrote:
> Re-implement sfq_change() and enable Qdisc_opts.change so "tc qdisc
> change" will work.
> 

> +static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
> +{
> +	...
> +
> +	/* finish up */
> +	if (q->perturb_period) {
> +		q->perturb_timer.expires = jiffies + q->perturb_period;
> +		add_timer(&q->perturb_timer);
> +	} else {
> +		q->perturbation = 0;


Seems counter-productive to explicitly set it to zero since
it was still used during tranfering the packets with the
old value. So I'd suggest to remove this or alternatively
set it to the final value *before* transfering the packets.
