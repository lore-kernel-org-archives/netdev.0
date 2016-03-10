From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH iproute2 v2 1/1] tc: introduce IFE action
Date: Thu, 10 Mar 2016 07:42:29 -0500
Message-ID: <56E16BB5.4070802@mojatatu.com>
References: <1457525076-6923-1-git-send-email-jhs@emojatatu.com>
 <1457525076-6923-2-git-send-email-jhs@emojatatu.com>
 <20160309131214.GB27306@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Phil Sutter <phil@nwl.cc>, shemming@brocade.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34200 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbcCJMoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 07:44:12 -0500
Received: by mail-io0-f194.google.com with SMTP id z76so7947138iof.1
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2016 04:44:12 -0800 (PST)
In-Reply-To: <20160309131214.GB27306@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-03-09 08:12 AM, Phil Sutter wrote:
> On Wed, Mar 09, 2016 at 07:04:36AM -0500, Jamal Hadi Salim wrote:
>> +static void ife_explain(void)
>> +{
>> +	fprintf(stderr,
>> +		"Usage:... ife {decode|encode} {ALLOW|USE} [dst DMAC] [src SMAC] [type TYPE] [CONTROL] [index INDEX]\n");
>
> I'm just nitpicking here, but this syntax implies that ALLOW and USE are
> mandatory and mutually exclusive. Looking at the code they're neither
> (although specifying both might not make sense). OTOH you could probably
> 'use mark' and 'allow prio'. So I'd suggest '[ALLOW] [USE]' instead.
>

Maybe we need to come up with some consistent regex/bnf
scheme. And then lets review all usage code and fix. Here are the rules
for this case:
Default: "allow" will be used for all metadata.
You can specify zero or more "allows", one per metadata
You can specify zero or more "use", one per metadata.

This is why my thinking was it was going to read
[ALLOW|USE] which needed to read as [ALLOW|USE]*

Example, I dont see "{..}" making good sense in any bnf/regex scheme.

>> +	fprintf(stderr,
>> +		"\tALLOW := Encode direction. Allows encoding specified metadata\n"
>> +		"\t\t e.g \"allow mark\"\n"
>> +		"\tUSE := Encode direction. Enforce Static encoding of specified metadata\n"
>> +		"\t\t e.g \"use mark 0x12\"\n"
>
> I'm missing a list of what actual keywords can be given, but after all
> this is just a help text and a man page will provide much more detail
> anyway (which you are about to submit too, are you? :).
>

Phil, Phil - someday, yes ;->

> Apart from that:
>
> Acked-by: Phil Sutter <phil@nwl.cc>
>

Lets please get this in and we can then do a general check on all.

cheers,
jamal
