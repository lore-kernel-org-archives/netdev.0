From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 6/7] Make qdisc changeable.
Date: Mon, 06 Aug 2007 14:06:12 +0200
Message-ID: <46B70EB4.70408@trash.net>
References: <11857548771998-git-send-email-bugfood-ml@fatooh.org> <11857548783311-git-send-email-bugfood-ml@fatooh.org> <46ADF18A.4060008@trash.net> <46B68BBE.9010307@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37072 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932228AbXHFMGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 08:06:30 -0400
In-Reply-To: <46B68BBE.9010307@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corey Hickey wrote:
> Patrick McHardy wrote:
> 
>>> +    if ((err = sfq_q_init(&tmp, opt)))
>>> +        return err;
>>
>>
>>
>> This will also use defaults for all unspecified values. It would
>> be more consistent with other qdiscs to only change those values
>> that are actually specified, so something like "tc qdisc change ...
>> perturb 10" will *only* change the perturbation parameter.
> 
> 
> I'm fixed this for all the parameters except one--your example above.
> Since 0 is a valid value for perturb, I can't see any clever way to
> differentiate between the user specifying "perturb 0" or leaving perturb
> unspecified. Either way, opt->perturb_period is 0.
> 
> The only way I can see would be to add another member, say,
> opt->perturb_specified, and use that accordingly. Unfortunately, this
> would break usage of sfq with older versions of tc, so I'm hoping
> there's a better approach.
> 
> Do you have any suggestions? I've looked at the other qdisc files and I
> don't see any other instances like this.


Maybe use the nested compat attribute and split the base SFQ
struct in the individual members ..
