From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: Why can't we SNAT (or inverse DNAT) in PREROUTING?
Date: Fri, 26 Jun 2015 16:35:54 -0700
Message-ID: <CALCETrVupw4uJN68skaUJH+zrEyGt7MagfMeTpdTqb1zQ7FB5w@mail.gmail.com>
References: <CALCETrWRv5S_X=MQRGwO-NR+XrQc2o-EnooHFN0V41xqJEY8sA@mail.gmail.com>
 <20150626203249.GA28820@electric-eye.fr.zoreil.com> <CALCETrUR9VKJ0jJwqF79Jm6Y954yhMrA=ifzRWCvvgHzOpgzag@mail.gmail.com>
 <20150626224825.GB28820@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:33957 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754940AbbFZXgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 19:36:15 -0400
Received: by lagx9 with SMTP id x9so72089404lag.1
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 16:36:14 -0700 (PDT)
In-Reply-To: <20150626224825.GB28820@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2015 at 3:48 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Andy Lutomirski <luto@amacapital.net> :
>> [re-add netdev -- I assume you meant to reply all]
>
> Thanks. Late friday.
>
>> On Fri, Jun 26, 2015 at 1:32 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
>> > Andy Lutomirski <luto@amacapital.net> :
>> > [...]
>> >> Could we add some option to do SNAT and inverse DNAT before routing?
>> >
>> > I haven't used it for ages but what's wrong with iptables + fwmark ?
>> >
>> > It takes place in PREROUTING.
>>
>> This works, but it seems unnecessarily painful.  It means that all of
>> my policy rules have to be duplicated with fwmark rules based on '-m
>> conntrack' or similar.
>
> I'd rather say that the fwmark rules will duplicate the SNAT rules since
> your routing policy depends on the post SNAT source addresses. You'd
> be right to complain it does not really help :o)
>
>> Shouldn't the order of operations be:
>>
>> 1. Check rp_filter.
>>
>> 2. Handle NAT.
>>
>> 3. Routing decision.
>>
>> ?
>
> The admittedly painful fwmark part would still be needed for pre-NAT
> source address based policy routing (assuming SNAT loses valuable policy
> information). Life would be easier for your current requirements but
> some different policy requirements would be unable to avoid the
> fwmark/mangle style stuff.

What kind of policy routing would care about the pre-NAT source
address?  AIUI, the usual use of policy routing is to *route*, not to
filter.  But maybe I'm missing something.

>
> Btw, the suggested scheme implies that filtering between SNAT and DNAT
> would be done before routing, thus without INPUT vs FORWARD tainting.

What do you mean by "filtering between SNAT and DNAT"?

--Andy
