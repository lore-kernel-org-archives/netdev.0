From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: Why can't we SNAT (or inverse DNAT) in PREROUTING?
Date: Fri, 26 Jun 2015 14:18:36 -0700
Message-ID: <CALCETrUR9VKJ0jJwqF79Jm6Y954yhMrA=ifzRWCvvgHzOpgzag@mail.gmail.com>
References: <CALCETrWRv5S_X=MQRGwO-NR+XrQc2o-EnooHFN0V41xqJEY8sA@mail.gmail.com>
 <20150626203249.GA28820@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:35938 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931AbbFZVS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 17:18:56 -0400
Received: by obctg8 with SMTP id tg8so74378975obc.3
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 14:18:56 -0700 (PDT)
In-Reply-To: <20150626203249.GA28820@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[re-add netdev -- I assume you meant to reply all]

On Fri, Jun 26, 2015 at 1:32 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Andy Lutomirski <luto@amacapital.net> :
> [...]
>> Could we add some option to do SNAT and inverse DNAT before routing?
>
> I haven't used it for ages but what's wrong with iptables + fwmark ?
>
> It takes place in PREROUTING.

This works, but it seems unnecessarily painful.  It means that all of
my policy rules have to be duplicated with fwmark rules based on '-m
conntrack' or similar.

Shouldn't the order of operations be:

1. Check rp_filter.

2. Handle NAT.

3. Routing decision.

?

--Andy

>
> --
> Ueimor



-- 
Andy Lutomirski
AMA Capital Management, LLC
