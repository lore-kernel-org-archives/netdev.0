From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH next-next 0/7] net: Cleanup IPv6 ip tunnels
Date: Mon, 2 May 2016 12:42:19 -0700
Message-ID: <CAKgT0UdksS3oUS65ne0j43WTwCMX_MNVOzmYhVDXD2_L=NGOCQ@mail.gmail.com>
References: <1461975141-954269-1-git-send-email-tom@herbertland.com>
	<CAKgT0UfwyZW7kifpU18xtwT77=Zex3AzJp=xry=siW1NVCyX+A@mail.gmail.com>
	<CALx6S379KxUkLRaE70AtaPgM8NqEieavd1+hcX=Z4Jfdn=CFDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:38751 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754858AbcEBTmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 15:42:20 -0400
Received: by mail-ig0-f176.google.com with SMTP id m9so1759407ige.1
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 12:42:20 -0700 (PDT)
In-Reply-To: <CALx6S379KxUkLRaE70AtaPgM8NqEieavd1+hcX=Z4Jfdn=CFDw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 2, 2016 at 12:32 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Fri, Apr 29, 2016 at 6:00 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Fri, Apr 29, 2016 at 5:12 PM, Tom Herbert <tom@herbertland.com> wrote:
>>> The IPv6 tunnel code is very different from IPv4 code. There is a lot
>>> of redundancy with the IPv4 code, particularly in the GRE tunneling.
>>>
>>> This patch set cleans up the tunnel code to make the IPv6 code look
>>> more like the IPv4 code and use common functions between the two
>>> stacks where possible.
>>>
>>> This work should make it easier to maintain and extend the IPv6 ip
>>> tunnels.
>>>
>>> Items in this patch set:
>>>   - Cleanup IPv6 tunnel receive path (ip6_tnl_rcv). Includes using
>>>     gro_cells and exporting ip6_tnl_rcv so the ip6_gre can call it
>>>   - Move GRE functions to common header file (tx functions) or
>>>     gre_demux.c (rx functions like gre_parse_header)
>>>   - Call common GRE functions from IPv6 GRE
>>>   - Create ip6_tnl_xmit (to be like ip_tunnel_xmit)
>>>
>>> Tested:
>>>   Ran super_netperf tests for TCP_RR and TCP_STREAM for:
>>>     - IPv4 over gre, gretap, gre6, gre6tap
>>>     - IPv6 over gre, gretap, gre6, gre6tap
>>>     - ipip
>>>     - ip6ip6
>>>     - ipip/gue
>>>     - IPv6 over gre/gue
>>>     - IPv4 over gre/gue
>>
>> You should probably add 2 additional test cases.  One for IPv4 GRE/GUE
>> w/ checksum on the GRE header, and same for IPv6.  It was broken
>> previously in terms of offloads so we need to make sure we don't
>> introduce a regression and break it again.
>>
> Hi Alexander,
>
> I did test GRE/GUE with checksum and remcsum for IPv4, that works okay.
>
> Support for GUE with IPv6 is in the next patch set I am working on.
>
> Thanks,
> Tom

Just so it is clear I am talking about having a checksum in the GRE
header, not the GUE header.  If there is a GRE checksum present we
have to force software segmentation since we don't have any means of
pointing to the header in a way that is meaningful for hardware.  As
long as we don't see any regressions I am good with these changes.

Thanks.

- Alex
