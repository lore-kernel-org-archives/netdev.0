From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] rtnl: don't account unused struct ifla_port_vsi
 in rtnl_port_size
Date: Fri, 17 Feb 2017 21:40:41 +0100
Message-ID: <58A75FC9.50107@iogearbox.net>
References: <8edb70077925c6924eac17dfc3c23cbc31c0529a.1487292448.git.daniel@iogearbox.net> <20170217.145701.1739857350079752194.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40363 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934090AbdBQUlB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 15:41:01 -0500
In-Reply-To: <20170217.145701.1739857350079752194.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/17/2017 08:57 PM, David Miller wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Fri, 17 Feb 2017 01:56:11 +0100
>
>> When allocating rtnl dump messages, struct ifla_port_vsi is never dumped,
>> so we can save header plus payload in rtnl_port_size(). Infact, attribute
>> IFLA_PORT_VSI_TYPE and struct ifla_port_vsi are not used anywhere in
>> the kernel. We only need to keep the nla policy should applications in
>> user space be filling this out. Same NLA_BINARY issue exists as was fixed
>> in 364d5716a7ad ("rtnetlink: ifla_vf_policy: fix misuses of NLA_BINARY")
>> and others, but then again IFLA_PORT_VSI_TYPE is not used anywhere, so
>> just add a comment that it's unused.
>>
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>> ---
>>   ( Found while reviewing NLA_BINARY longer time ago. )
>
> Applied, but whether or not this is emitted it controlled by how a driver
> implements ->ndo_get_vf_port().
>
> Therefore, in the future some driver could fill this in.

Agree, in that case, it can be undone; when I checked, this part
was added 7 years ago via 57b610805ce9 ("net: Add netlink support
for virtual port management (was iovnl)") and never had a single
user since then.
