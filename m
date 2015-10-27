From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Missing IPv4 routes
Date: Tue, 27 Oct 2015 13:29:10 -0700
Message-ID: <562FDE96.3030400@gmail.com>
References: <562AA7D3.9030905@vultr.com> <562AB578.9090107@gmail.com>
 <562B8856.6070501@vultr.com> <562E46BA.7060904@gmail.com>
 <562E5B69.6080108@vultr.com> <562FD820.5050901@gameservers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Brian Rak <brak@gameservers.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34342 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965251AbbJ0U3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 16:29:11 -0400
Received: by padhk11 with SMTP id hk11so232570989pad.1
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 13:29:11 -0700 (PDT)
In-Reply-To: <562FD820.5050901@gameservers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2015 01:01 PM, Brian Rak wrote:
> (Existing email got kinda messy, starting over again):
>
> So, I'm having an issue with the kernel where if I add a bunch of 
> routes, I see some of them go "missing".  They don't show up in the 
> 'ip -4 route' list, but they do show up if I do 'ip -4 route get X'.
>
> I managed to come up with a simple set of reproduction commands:
>
> ip link add veth0 type veth peer name veth1
> ip link set veth0 up
> ip link set veth1 up
>
> ip route add 108.61.171.119/32 dev veth0  scope link
> ip route add 108.61.171.141/32 dev veth1  scope link
> ip route add 108.61.171.223/32 dev veth1  scope link
> ip route add 108.61.171.250/32 dev veth1  scope link
> ip route add 108.61.171.247/32 dev veth1  scope link
>
> ip route show
>
> In the route show, you'll see 108.61.171.250/32 and 108.61.171.247/32 
> missing completely.
>
> I did a lot of bisecting, and traced it down to this commit:
>
> commit 8be33e955cb959dabc1a6eef0b7356fe8cf73fa6
> Author: Alexander Duyck <alexander.h.duyck@redhat.com>
> Date:   Wed Mar 4 14:59:19 2015 -0800
>
>     fib_trie: Fib walk rcu should take a tnode and key instead of a 
> trie and a leaf
>
> The commit immediately prior to this one 
> (7289e6ddb633aaee6ccea2bd2e410654c47b29a6) works fine.
>
> I tried the off-by-one fix from 
> e55ffaf457bcc8ec4e9d9f56f955971f834d65b3, however this doesn't appear 
> to help at all.   This code is a little above my head, so I don't 
> really understand what exactly is broken here.

I'll take a look at it and see if I can come up with a fix by this 
afternoon.

Thanks.

- Alex
