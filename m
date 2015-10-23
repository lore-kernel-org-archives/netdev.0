From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: ip_no_pmtu_disc and UDP
Date: Fri, 23 Oct 2015 10:01:50 -0700
Message-ID: <CAK3+h2x89hXJjK+OqnSjQEdTxDXkRsAixaL4L31SLkc7bJNMfQ@mail.gmail.com>
References: <CAK3+h2wFfh+HE78kHoWwgc9vyTCLWM90C4RQ=uTRk8551-jQ7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:36623 "EHLO
	mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbbJWRBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 13:01:52 -0400
Received: by lffz202 with SMTP id z202so90695230lff.3
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 10:01:50 -0700 (PDT)
In-Reply-To: <CAK3+h2wFfh+HE78kHoWwgc9vyTCLWM90C4RQ=uTRk8551-jQ7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 I think the no_pmtu_disc could be renamed to pmtu_disc to be less
confusion to users.

pmtu_disc: IP_PMTUDISC_DONT, clear DF bit
pmtu_disc: IP_PMTUDISC_WANT, set DF bit

 just my .2 cents

On Fri, Oct 23, 2015 at 9:45 AM, Vincent Li <vincent.mc.li@gmail.com> wrote:
> Hi,
>
> It looks ip_no_pmtu_disc setting does not affect UDP IP packet DF bit
> setting, is that intended behavior? echo 0, 1, 2, 3 respectively to
> ip_no_pmtu_disc, UDP IP packet always have DF bit cleared, unless use
> IP_PMTUDISC_DO on IP_MTU_DISCOVER as ip man page says.
>
> in inet_create, seems to prove that.
>
>        if (net->ipv4.sysctl_ip_no_pmtu_disc)
>                 inet->pmtudisc = IP_PMTUDISC_DONT;
>         else
>                 inet->pmtudisc = IP_PMTUDISC_WANT;
>
> so I am wondering why UDP is excluded by ip_no_pmtu_disc, why in
> inet_create, not assign each individual ip_no_pmtu_disc setting to
> inet->pmtudisc but only check true and assign IP_PMTUDISC_DONT or
> IP_PMTUDISC_WANT only.
>
> Thanks
>
> Vincent
