From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH -next] net: sched: use counter to break reclassify loops
Date: Wed, 13 May 2015 08:04:27 -0400
Message-ID: <55533DCB.2070703@mojatatu.com>
References: <1431366641-24735-1-git-send-email-fw@strlen.de> <5551E62D.5040507@mojatatu.com> <20150512130029.GA22387@breakpoint.cc> <55533321.302@mojatatu.com> <20150513112958.GA6179@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:33520 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965081AbbEMME3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 08:04:29 -0400
Received: by iebgx4 with SMTP id gx4so29426761ieb.0
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 05:04:29 -0700 (PDT)
In-Reply-To: <20150513112958.GA6179@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/13/15 07:29, Florian Westphal wrote:
> Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> Yes, but, if we use your example above then:
>
> tc_classify called
>    limit 0
>      tc_classify_compat called, ret RECLASSIFY
>    limit 1
>      tc_classify_compat called, ret RECLASSIFY
>    limit 2
>      tc_classify_compat called, ret PIPE (== 3)
>    tc_classify returns 3
> tc_classify called
>    limit 0
>    ...
>
> So we don't toss skb since any return value other than RECLASSIFY
> will make tc_classify() return to its caller, and when caller invokes
> tc_classify again the limit variable is set to 0 again.
>
> Does that make sense to you?
>

I think you are right.

I am probably conflating the inner action loop execution with this
outer one. I will think some more about it and if i can come up with
other scenario.
In any case, lets not slow this down; please add my acked-by and if
i can think of something i will post. I have to take off, so i will go
quiet for a while.

cheers,
jamal
