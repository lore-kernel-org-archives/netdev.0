From: Mike Manning <mmanning@brocade.com>
Subject: Re: [PATCH] net: ipv6: Do not fix up linklocal and loopback addresses
Date: Sun, 17 Apr 2016 19:13:57 +0100
Message-ID: <5713D265.60506@brocade.com>
References: <5711AA52.6010400@brocade.com> <5711ADD1.2030904@brocade.com>
 <571283EA.6020307@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:41934 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750730AbcDQSOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2016 14:14:21 -0400
In-Reply-To: <571283EA.6020307@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/16/2016 07:26 PM, David Ahern wrote:
> On 4/15/16 9:13 PM, Mike Manning wrote:
>> f1705ec197e7 added the option to retain user configured addresses on an
>> admin down. A comment to one of the later revisions suggested using the
>> IFA_F_PERMANENT flag rather than adding a user_managed boolean to the
>> ifaddr struct. A side effect of this change is that link local and
>> loopback addresses are also retained which is not part of the objective
>> of f1705ec197e7. Add check so that these addresses are not fixed up,
>> given that a related fix 70af921db6f8 ensures that they are not kept in
>> the first place, otherwise this incorrect fixup triggers a crash in fib6.
> 
> oops in fib6_del?
>
 
[  285.734883]  [<ffffffff8125ad15>] ? dump_stack+0x5c/0x77
[  285.734887]  [<ffffffff8105d907>] ? warn_slowpath_common+0x77/0xb0
[  285.734889]  [<ffffffff814f3e40>] ? fib6_clean_tohost+0x50/0x50
[  285.734891]  [<ffffffff814fbe3e>] ? fib6_del+0x22e/0x290
[  285.734893]  [<ffffffff814fbf22>] ? fib6_clean_node+0x82/0x120
[  285.734895]  [<ffffffff814f9a0d>] ? fib6_walk_continue+0x16d/0x1a0
[  285.734897]  [<ffffffff814f9ad4>] ? fib6_walk+0x54/0x80
[  285.734899]  [<ffffffff814f9b42>] ? fib6_clean_tree+0x42/0x50
[  285.734901]  [<ffffffff814fbea0>] ? fib6_del+0x290/0x290
[  285.734902]  [<ffffffff814f3e40>] ? fib6_clean_tohost+0x50/0x50
[  285.734904]  [<ffffffff814f9ba8>] ? __fib6_clean_all+0x58/0x90
[  285.734906]  [<ffffffff814f9326>] ? rt6_ifdown+0x36/0x1e0
[  285.734908]  [<ffffffff814fbf0f>] ? fib6_clean_node+0x6f/0x120
[  285.734911]  [<ffffffff814eeb6b>] ? addrconf_ifdown+0x3b/0x580
[  285.734913]  [<ffffffff814f9b42>] ? fib6_clean_tree+0x42/0x50
[  285.734914]  [<ffffffff814f1ea0>] ? addrconf_notify+0xf0/0xb10
[  285.734916]  [<ffffffff814f9bb0>] ? __fib6_clean_all+0x60/0x90

>> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
>> Signed-off-by: Mike Manning <mmanning@brocade.com>
>> ---
> 
> for the change
> Acked-by: David Ahern <dsa@cumulusnetworks.com>
> 
