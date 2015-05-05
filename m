From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH -next 0/5] replace skb tc_verd member with 3 dedicated
 bit flags
Date: Tue, 05 May 2015 07:58:40 -0400
Message-ID: <5548B070.80502@mojatatu.com>
References: <1430765318-13788-1-git-send-email-fw@strlen.de> <5548ABF8.5080806@mojatatu.com> <20150505114733.GE17061@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:33414 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbbEEL6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 07:58:51 -0400
Received: by oica37 with SMTP id a37so142654023oic.0
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 04:58:50 -0700 (PDT)
In-Reply-To: <20150505114733.GE17061@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/05/15 07:47, Florian Westphal wrote:
> Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> Initial feedback on the series:
>> - Can you keep the macros around? eg SET_TC_NCLS is more readable
>> than skb->tc_nocls = 1 also hides the bit details.
>
> I beg to differ, sorry :-/
>
> We use blah:1 everywhere else in sk_buff, only tc is different and
> its not obvious (to me) how tc_verd is being used and for what.
>
> Or are you saying that should redefine SET_TC_NCLS to something like
>
> #define SET_TC_NCLS(skb)	(skb)->tc_nocls = 1
>
> ?
>

It is borderline questionable for 1 bit but for consistency i
suggest you do what was there before. I pointed to nocls but
i meant the comment generically because previous code you are
changing intended to use the macros.
In any case I will leave it up to you.

>> I think the ones that are no longer needed should just be deleted
>> as opposed to what you and Alexei did earlier.
>
> Fair enough, I can do that.

Perhaps even as a first patch that move would be useful.

>
>> - We need two bits for the location (ingress, egress, from stack)
>> from stack being 0 i.e when it is not set implicitly it is from the
>> host stack then we can check for ingress or egress when we choose.
>
> Hmm, are you sure?  How is that used?
>

As example, when something like
if (!(at & AT_EGRESS))
implies it is either from ingress or the stack.
It does not only from ingress.

> In fact ifb will BUG() if neither AT_INGRESS or AT_EGRESS was set
> in G_TC_FROM().
>

Yes, because you cant send directly from the stack host to ifb. You
can only redirect to it. If we ever end there from the host we should
bug()

cheers,
jamal
