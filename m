From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v4] fib_rules: Added NLM_F_EXCL support to fib_nl_newrule
Date: Wed, 29 Jun 2016 13:38:54 -0600
Message-ID: <c5e9792a-592b-b01a-9f05-b8db6c4da84c@cumulusnetworks.com>
References: <57737722.6000101@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Mateusz Bajorski <mateusz.bajorski@nokia.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34591 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbcF2Tiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 15:38:54 -0400
Received: by mail-pa0-f41.google.com with SMTP id bz2so20320073pad.1
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 12:38:54 -0700 (PDT)
In-Reply-To: <57737722.6000101@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/29/16 1:22 AM, Mateusz Bajorski wrote:
> When adding rule with NLM_F_EXCL flag then check if the same rule exist.
> If yes then exit with -EEXIST.
>
> This is already implemented in iproute2:
>         if (cmd == RTM_NEWRULE) {
>                 req.n.nlmsg_flags |= NLM_F_CREATE|NLM_F_EXCL;
>                 req.r.rtm_type = RTN_UNICAST;
>         }
>
> Tested ipv4 and ipv6 with net-next linux on qemu x86
>
> expected behavior after patch:
> localhost ~ # ip rule
> 0:    from all lookup local
> 32766:    from all lookup main
> 32767:    from all lookup default
> localhost ~ # ip rule add from 10.46.177.97 lookup 104 pref 1005
> localhost ~ # ip rule add from 10.46.177.97 lookup 104 pref 1005
> RTNETLINK answers: File exists
> localhost ~ # ip rule
> 0:    from all lookup local
> 1005:    from 10.46.177.97 lookup 104
> 32766:    from all lookup main
> 32767:    from all lookup default
>
> There was already topic regarding this but I don't see any changes
> merged and problem still occurs.
> https://lkml.kernel.org/r/1135778809.5944.7.camel+%28%29+localhost+%21+localdomain
>
> Signed-off-by: Mateusz Bajorski <mateusz.bajorski@nokia.com>
> ---
> Changes in v2: section moved to new place where new rule is already built
> Changes in v3: compare moved to helper, added fr_net compare
> Changes in v4: added l3mdev compare
>
>  net/core/fib_rules.c | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 49 insertions(+)
>

Acked-by: David Ahern <dsa@cumulusnetworks.com>
