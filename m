From: Florian Westphal <fw@strlen.de>
Subject: Re: nf_nat_pptp 4.12.3 kernel lockup/reboot
Date: Mon, 24 Jul 2017 18:19:44 +0200
Message-ID: <20170724161944.GB23964@breakpoint.cc>
References: <69c0c47e920e763bce702521baae9caa@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Florian Westphal <fw@strlen.de>
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:48088 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751370AbdGXQV3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 12:21:29 -0400
Content-Disposition: inline
In-Reply-To: <69c0c47e920e763bce702521baae9caa@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko <nuclearcat@nuclearcat.com> wrote:
> Hi,
> 
> I am trying to upgrade kernel 4.11.8 to 4.12.3 (it is a nat/router, handling
> approx 2gbps of pppoe users traffic) and noticed that after while server
> rebooting(i have set reboot on panic and etc).
> I can't run serial console, and in pstore / netconsole there is nothing.
> Best i got is some very short message about softlockup in ipmi, but as
> storage very limited there - it is near useless.
> 
> By preliminary testing (can't do it much, as it's production) - it seems
> following lines causing issue, they worked in 4.11.8 and no more in 4.12.3.

Wild guess here, does this help?

diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -266,6 +266,8 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
                help = nf_ct_helper_ext_add(ct, helper, flags);
                if (help == NULL)
                        return -ENOMEM;
+              	if (!nf_ct_ext_add(ct, NF_CT_EXT_NAT, flags));
+                       return -ENOMEM;
        } else {
                /* We only allow helper re-assignment of the same sort since
                 * we cannot reallocate the helper extension area.
