From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: [PATCH 6/7] Make qdisc changeable.
Date: Sun, 05 Aug 2007 19:47:26 -0700
Message-ID: <46B68BBE.9010307@fatooh.org>
References: <11857548771998-git-send-email-bugfood-ml@fatooh.org> <11857548783311-git-send-email-bugfood-ml@fatooh.org> <46ADF18A.4060008@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:49634 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753308AbXHFCrZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Aug 2007 22:47:25 -0400
In-Reply-To: <46ADF18A.4060008@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
>> +	if ((err = sfq_q_init(&tmp, opt)))
>> +		return err;
> 
> 
> This will also use defaults for all unspecified values. It would
> be more consistent with other qdiscs to only change those values
> that are actually specified, so something like "tc qdisc change ...
> perturb 10" will *only* change the perturbation parameter.

I'm fixed this for all the parameters except one--your example above.
Since 0 is a valid value for perturb, I can't see any clever way to
differentiate between the user specifying "perturb 0" or leaving perturb
unspecified. Either way, opt->perturb_period is 0.

The only way I can see would be to add another member, say,
opt->perturb_specified, and use that accordingly. Unfortunately, this
would break usage of sfq with older versions of tc, so I'm hoping
there's a better approach.

Do you have any suggestions? I've looked at the other qdisc files and I 
don't see any other instances like this.

Thanks,
Corey
