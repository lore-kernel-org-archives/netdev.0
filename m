From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 extension header privileges
Date: Sat, 21 May 2016 02:20:54 +0200
Message-ID: <1e22f140-920e-0d1c-4a43-03780fb380a8@stressinduktion.org>
References: <CALx6S36x2+HBLSYVBi0+rQAgejbVvvFF7fr0P13cTspxpJQCLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:35395 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751422AbcEUAU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 20:20:58 -0400
In-Reply-To: <CALx6S36x2+HBLSYVBi0+rQAgejbVvvFF7fr0P13cTspxpJQCLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21.05.2016 00:37, Tom Herbert wrote:
> Hi,
> 
> In ipv6_sockglue.c I noticed:
> 
> /* hop-by-hop / destination options are privileged option */
> retv = -EPERM;
> if (optname != IPV6_RTHDR && !ns_capable(net->user_ns, CAP_NET_RAW))
>            break;
> 
> Can anyone provide that rationale as to why these are privileged ops?

There are some options inherently protocol depending like the jumbo
payload option, which should be under control of the kernel, or the
router alert option for igmp, which causes packets to be steered towards
the slow/software path of routers, which can be used for DoS attacks.

Setting CALIPSO options in IPv6 on packets as users would defeat the
whole CALIPSO model, etc.

The RFC3542 requires at least some of the options in dst/hop-by-hop
extensions to be only be settable by privileged users. More fine-grained
parsing and setting of those options has never been implemented.

AFAIK people worried about the parsing overhead and thus decided to
block it for ordinary users.

Bye,
Hannes
