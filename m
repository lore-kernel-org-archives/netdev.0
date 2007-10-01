From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: [PATCH 02/10] Preparatory refactoring part 2.
Date: Mon, 01 Oct 2007 13:46:51 -0700
Message-ID: <47015CBB.90109@fatooh.org>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org> <11910199773306-git-send-email-bugfood-ml@fatooh.org> <4700F715.9000200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:41586 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752898AbXJAUq6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 16:46:58 -0400
In-Reply-To: <4700F715.9000200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Corey Hickey wrote:
>> The sfq_destroy() --> sfq_q_destroy() change looks pointless here,
>> but it's cleaner to split now and add code to sfq_q_destroy() in a
>> later patch.
>>
>> +static void sfq_destroy(struct Qdisc *sch)
>> +{
>> +	struct sfq_sched_data *q = qdisc_priv(sch);
>> +	sfq_q_destroy(q);
>> +}
> 
> 
> It does look pointless, after applying all patches sfq_destroy still
> remains a simply wrapper around sfq_q_destroy.

It does remain a wrapper, but both functions are used. It doesn't have 
to be this way, but I wanted to avoid duplicating code and I didn't see 
a better layout.

sfq_q_destroy is used in sfq_q_init if a kcalloc fails. sfq_q_init knows 
nothing about "struct Qdisc *sch", so it can't call sfq_destroy.

sfq_destroy is still marked as the destroy function in sfq_qdisc_ops.

-Corey
