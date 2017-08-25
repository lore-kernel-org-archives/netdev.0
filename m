From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: nf_nat_pptp 4.12.3 kernel lockup/reboot
Date: Fri, 25 Aug 2017 10:15:56 +0300
Message-ID: <f3d7f36efa579a6f428341e3964bc1df@nuclearcat.com>
References: <69c0c47e920e763bce702521baae9caa@nuclearcat.com>
 <20170724161944.GB23964@breakpoint.cc>
 <20170724162039.GC23964@breakpoint.cc>
 <f31c9ddfc1d4e02ff7fc16d3a0955841@nuclearcat.com>
 <20170825052137.GF15739@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:40182 "EHLO nuclearcat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754339AbdHYHP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 03:15:59 -0400
In-Reply-To: <20170825052137.GF15739@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-08-25 08:21, Florian Westphal wrote:
> Denys Fedoryshchenko <nuclearcat@nuclearcat.com> wrote:
>> >>> I am trying to upgrade kernel 4.11.8 to 4.12.3 (it is a nat/router, handling
>> >>> approx 2gbps of pppoe users traffic) and noticed that after while server
>> >>> rebooting(i have set reboot on panic and etc).
>> >>> I can't run serial console, and in pstore / netconsole there is nothing.
>> >>> Best i got is some very short message about softlockup in ipmi, but as
>> >>> storage very limited there - it is near useless.
>> >>>
>> >>> By preliminary testing (can't do it much, as it's production) - it seems
>> >>> following lines causing issue, they worked in 4.11.8 and no more in 4.12.3.
>> >>
>> >>Wild guess here, does this help?
>> >>
>> >>diff --git a/net/netfilter/nf_conntrack_helper.c
>> >>b/net/netfilter/nf_conntrack_helper.c
>> >>--- a/net/netfilter/nf_conntrack_helper.c
>> >>+++ b/net/netfilter/nf_conntrack_helper.c
>> >>@@ -266,6 +266,8 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct,
>> >>struct nf_conn *tmpl,
>> >>                help = nf_ct_helper_ext_add(ct, helper, flags);
>> >>                if (help == NULL)
>> >>                        return -ENOMEM;
>> >>+              	if (!nf_ct_ext_add(ct, NF_CT_EXT_NAT, flags));
>> >
>> >sigh, stupid typo, should be no ';' at the end above.
>> Sorry, is there any plans to push this to 4.12 stable queue?
> 
> No, sorry, this patch adds the extension for all connections
> that use a helper, but the nat extension is only used/required by pptp
> helper (and masquerade).
> 
> Thing is that this patch should not be needed, I will have
> to review pptp again, maybe i missed a case where the extension is not
> added.
> 
> Do you happen to have an oops backtrace?
> 
> That might speed this up a bit.
There is nothing in netconsole, and also nothing ERST pstore, i found 
reason just by guessing.
Its totally headless also (no screen, no serial console).
I can try to attach USB serial for serial console, but not sure it will 
help.
If there is any other way to catch - i can try it, but as it's 
production server, so i can't "crash it" more than once per day.
