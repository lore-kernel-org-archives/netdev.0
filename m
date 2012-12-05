From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: ip_rt_min_pmtu
Date: Wed, 5 Dec 2012 10:46:11 +0200
Message-ID: <CAKoUArn0EYaeebFXtCgqDSYeJD2oFKUfns7Lbk7Rsg=N=pnpHA@mail.gmail.com>
References: <50BE654D.2010602@shakaweb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Christopher Schramm <netdev@shakaweb.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:36440 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751699Ab2LEIqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 03:46:12 -0500
Received: by mail-qa0-f53.google.com with SMTP id a19so1504350qad.19
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2012 00:46:11 -0800 (PST)
In-Reply-To: <50BE654D.2010602@shakaweb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Just a short note:
RFC 791 indeed set 68 for internet module MTU.

But RFC 791 also declares 576 as PMTU:
"All hosts must be prepared to accept datagrams of up to 576 octets".
and it says also:
"The number 576 is selected to allow a reasonable sized data block to
be transmitted in addition to the required header information."

It seems that there is a distinction between a module sending MTU and
hosts receiving MTU.

Regarding the historical details of why it was sent at that time  -
I don't have an idea.

Regards,
Rami Rosen
http://ramirose.wix.com/ramirosen



On Tue, Dec 4, 2012 at 11:04 PM, Christopher Schramm
<netdev@shakaweb.org> wrote:
> Hi,
>
> I'm looking into an interesting detail of the Linux IPv4 implementation I
> stumbled upon during a University course.
>
> In route.c there's a value ip_rt_min_pmtu, defined as 512 + 20 + 20, that
> tells Linux a minimum PMTU to use, even if e. g. an ICMP message tells it to
> set a smaller one.
>
> Of course, this is not a problem in real world, but not standard-compliant,
> since RFC 791 defines a minimum MTU of 68 for IPv4. So I wonder what's the
> reason for the restriction.
>
> I looked into it and found that it appeared in Linux 2.3.15 with the
> following ID in route.c:
>
> v 1.71 1999/08/20 11:05:58 davem
>
> While it was not present in Linux 2.3.14 with:
>
> v 1.69 1999/06/09 10:11:02 davem
>
> I couldn't find any related discussion or patch on the LKML around that
> dates, so I'm asking you for any hints to find out the reason for
> implementing this lower bound.
>
> What I've found on the LKML is a topic around February 15th, 2001, titled
> "MTU and 2.4.x kernel", where Alexey Kuznetsov points out that the handling
> of "DF on syn frames" is broken for MTUs smaller than 128 and "Preventing
> DoSes requires to block pmtu discovery at 576 or at least 552".
>
> Does anybody know the actual reason for the change in 2.3.15? I first
> thought it's the common misinterpretation that 576 would be the lower bound
> for MTUs in IPv4, but I wonder why it was put in place as a patch years
> after the IPv4 implementation was already done. There seems to have been
> some clear reason for it. I also wonder why it has never been removed up to
> today if it's really nothing more than a mistake.
>
> Would be great if someone could help me shed some light on this.
>
> Regards
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
