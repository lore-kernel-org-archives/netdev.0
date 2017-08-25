From: Florian Westphal <fw@strlen.de>
Subject: Re: nf_nat_pptp 4.12.3 kernel lockup/reboot
Date: Fri, 25 Aug 2017 07:21:37 +0200
Message-ID: <20170825052137.GF15739@breakpoint.cc>
References: <69c0c47e920e763bce702521baae9caa@nuclearcat.com>
 <20170724161944.GB23964@breakpoint.cc>
 <20170724162039.GC23964@breakpoint.cc>
 <f31c9ddfc1d4e02ff7fc16d3a0955841@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:39096 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751829AbdHYFYO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 01:24:14 -0400
Content-Disposition: inline
In-Reply-To: <f31c9ddfc1d4e02ff7fc16d3a0955841@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko <nuclearcat@nuclearcat.com> wrote:
> >>> I am trying to upgrade kernel 4.11.8 to 4.12.3 (it is a nat/router, handling
> >>> approx 2gbps of pppoe users traffic) and noticed that after while server
> >>> rebooting(i have set reboot on panic and etc).
> >>> I can't run serial console, and in pstore / netconsole there is nothing.
> >>> Best i got is some very short message about softlockup in ipmi, but as
> >>> storage very limited there - it is near useless.
> >>>
> >>> By preliminary testing (can't do it much, as it's production) - it seems
> >>> following lines causing issue, they worked in 4.11.8 and no more in 4.12.3.
> >>
> >>Wild guess here, does this help?
> >>
> >>diff --git a/net/netfilter/nf_conntrack_helper.c
> >>b/net/netfilter/nf_conntrack_helper.c
> >>--- a/net/netfilter/nf_conntrack_helper.c
> >>+++ b/net/netfilter/nf_conntrack_helper.c
> >>@@ -266,6 +266,8 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct,
> >>struct nf_conn *tmpl,
> >>                help = nf_ct_helper_ext_add(ct, helper, flags);
> >>                if (help == NULL)
> >>                        return -ENOMEM;
> >>+              	if (!nf_ct_ext_add(ct, NF_CT_EXT_NAT, flags));
> >
> >sigh, stupid typo, should be no ';' at the end above.
> Sorry, is there any plans to push this to 4.12 stable queue?

No, sorry, this patch adds the extension for all connections
that use a helper, but the nat extension is only used/required by pptp
helper (and masquerade).

Thing is that this patch should not be needed, I will have
to review pptp again, maybe i missed a case where the extension is not
added.

Do you happen to have an oops backtrace?

That might speed this up a bit.
