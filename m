From: Robert Shearman <rshearma@brocade.com>
Subject: Re: MPLS decap with iproute2
Date: Mon, 7 Dec 2015 21:42:50 +0000
Message-ID: <5665FD5A.8000200@brocade.com>
References: <CAJm+voVUXPBXBRo98K6XS9pVEkN=fCJ4chRdQ=azcZO9ge9gEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: Sam Russell <sam.h.russell@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:16622 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755674AbbLGVnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 16:43:02 -0500
In-Reply-To: <CAJm+voVUXPBXBRo98K6XS9pVEkN=fCJ4chRdQ=azcZO9ge9gEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 19:42, Sam Russell wrote:
> Hi,
>
> I've had success with the iproute2 manpage example for encapsulating
> outgoing traffic in MPLS, but I've not found a way to add decap routes
> inbound.
>
> I've tried "ip route -f mpls add 100 dev lo" and other variations, but I
> get netlink errors back.
>
> Has this been built yet? Is there sample config that I can try out? I'm
> running a home-built 4.3 kernel + iproute2 built from head (on ubuntu
> 15.10) and am comfortable with perf and splashing around in the codebase if
> need be.

Hi Sam,

This certainly works on net-next, albeit with a bug on the subsequent 
"ip route -f mpls list" that I'll shortly be sending a patch for.

Have you first set an appropriate label table size? E.g.:

   $ sysctl net.mpls.platform_labels=1048575

If you intend to receive non-BOS traffic over your route above, then you 
should also make sure to enable mpls input on lo (and your actual input 
interfaces), otherwise the traffic will be dropped.

Thanks,
Rob
