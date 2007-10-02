From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 02/10] Preparatory refactoring part 2.
Date: Tue, 02 Oct 2007 05:19:07 +0200
Message-ID: <4701B8AB.20804@trash.net>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org> <11910199773306-git-send-email-bugfood-ml@fatooh.org> <4700F715.9000200@trash.net> <47015CBB.90109@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48480 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757AbXJBDTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 23:19:45 -0400
In-Reply-To: <47015CBB.90109@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corey Hickey wrote:
> Patrick McHardy wrote:
> 
>>> +static void sfq_destroy(struct Qdisc *sch)
>>> +{
>>> +    struct sfq_sched_data *q = qdisc_priv(sch);
>>> +    sfq_q_destroy(q);
>>> +}
>>
>>
>> It does look pointless, after applying all patches sfq_destroy still
>> remains a simply wrapper around sfq_q_destroy.
> 
> 
> It does remain a wrapper, but both functions are used. It doesn't have
> to be this way, but I wanted to avoid duplicating code and I didn't see
> a better layout.
> 
> sfq_q_destroy is used in sfq_q_init if a kcalloc fails. sfq_q_init knows
> nothing about "struct Qdisc *sch", so it can't call sfq_destroy.


Thats fine, I didn't realize it was used without the struct Qdisc *
context. Changing sfq_destroy to sfq_q_destroy(qdisc_priv(sch));
would be a bit nicer though.
