From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: iproute2 build error due to sr-ipv6 lwtunnel
Date: Thu, 04 May 2017 11:55:22 +0200
Message-ID: <590AFA8A.30602@iogearbox.net>
References: <590AF0C3.6070006@iogearbox.net> <3c0c0584-338d-47d0-76d4-e4408decc2c1@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33896 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751319AbdEDJzY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 05:55:24 -0400
In-Reply-To: <3c0c0584-338d-47d0-76d4-e4408decc2c1@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2017 11:28 AM, David Lebrun wrote:
> On 05/04/2017 11:13 AM, Daniel Borkmann wrote:
>> Hi David,
>>
>> I'm getting the following build error from e8493916a8ed ("iproute:
>> add support for SR-IPv6 lwtunnel encapsulation"). Reverting your
>> commit makes iproute2 build again for me. Please take a look.
>
> Hi Daniel,
>
> This is because linux/seg6.h does an include of linux/in6.h (cf kernel
> commit ea3ebc73b46fbdb049dafd47543bb22efaa09c8e "uapi: fix linux/seg6.h
> and linux/seg6_iptunnel.h userspace compilation errors"), and iproute2's
> include/utils.h requires the system /usr/include/resolv.h, which itself
> includes /usr/include/netinet/in.h, re-defining struct in6_addr.
>
> However, netinet/in.h protects some struct definitions with #ifndef
> __USE_KERNEL_IPV6_DEFS, which is explicitly defined in
> iproute_lwtunnel.c, thus avoiding this specific issue.
>
> What is your glibc version ?

Ok, I see, on one of my machines I have an old user space, but
latest net/net-next kernel (+ installed kernel headers) and
iproute2. glibc version there is 2.18.
