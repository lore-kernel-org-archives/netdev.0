From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [PATCH iproute2 1/1] tc: distinguish Add/Replace qdisc operations
Date: Fri, 27 Oct 2017 10:02:33 -0400
Message-ID: <85mv4clmdi.fsf@mojatatu.com>
References: <1509053408-18007-1-git-send-email-mrv@mojatatu.com>
        <20171027093648.7bd93253@shemminger-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:49406 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbdJ0OCg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 10:02:36 -0400
Received: by mail-io0-f196.google.com with SMTP id n137so12925972iod.6
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 07:02:36 -0700 (PDT)
In-Reply-To: <20171027093648.7bd93253@shemminger-XPS-13-9360> (Stephen
        Hemminger's message of "Fri, 27 Oct 2017 09:36:48 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> writes:

> On Thu, 26 Oct 2017 17:30:08 -0400
> Roman Mashak <mrv@mojatatu.com> wrote:
>
>> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
>> ---
>>  tc/tc_qdisc.c | 10 ++++++++++
>>  1 file changed, 10 insertions(+)
>> 
>> diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
>> index 1e9d909..493538c 100644
>> --- a/tc/tc_qdisc.c
>> +++ b/tc/tc_qdisc.c
>> @@ -231,6 +231,16 @@ int print_qdisc(const struct sockaddr_nl *who,
>>  	if (n->nlmsg_type == RTM_DELQDISC)
>>  		fprintf(fp, "deleted ");
>>  
>> +	if (n->nlmsg_type == RTM_NEWQDISC &&
>> +			(n->nlmsg_flags & NLM_F_CREATE) &&
>> +			(n->nlmsg_flags & NLM_F_REPLACE))
>> +		fprintf(fp, "replaced ");
>> +
>> +	if (n->nlmsg_type == RTM_NEWQDISC &&
>> +			(n->nlmsg_flags & NLM_F_CREATE) &&
>> +			(n->nlmsg_flags & NLM_F_EXCL))
>> +		fprintf(fp, "added ");
>> +
>>  	if (show_raw)
>>  		fprintf(fp, "qdisc %s %x:[%08x]  ",
>>  			rta_getattr_str(tb[TCA_KIND]),
>
> I am not sure about this. We don't do this for monitoring routes or addresses.

However we already do this for other TC components - actions and
filters, e.g. print_action() or print_filter().
