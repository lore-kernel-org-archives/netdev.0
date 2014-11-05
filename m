From: Florian Westphal <fw@strlen.de>
Subject: Re: mlx4+vxlan offload breaks gre tunnels
Date: Wed, 5 Nov 2014 17:53:51 +0100
Message-ID: <20141105165351.GA23131@breakpoint.cc>
References: <20141105150448.GA20776@breakpoint.cc>
 <545A4DB7.5010603@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>,
	Jesse Gross <jesse@nicira.com>, amirv@mellanox.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:51032 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753888AbaKEQxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 11:53:53 -0500
Content-Disposition: inline
In-Reply-To: <545A4DB7.5010603@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <ogerlitz@mellanox.com> wrote:
> On 11/5/2014 5:04 PM, Florian Westphal wrote:
> >tl,dr: all tcp packets sent via gre tunnel have broken tcp csum if vxlan offload
> >is enabled with mlx4 driver.
> >
> Yep, I can see now the problem. It comes into play with
> ConnectX3-pro NICs that support VXLAN offloads (but not with
> ConnectX3 NIC which don't) when you enable the offloads support on
> the CX3-pro.

[..]
> I think the best effort we can do now is
> 
> 1. come up with something such as the below patch for 3.18 which is
> back-ward portable for -stable kernels, it will only arm the hw
> offloads if the OS tells us there's VXLAN in action
> 
[..]
> 
> tested to work with the  following which is a bit different, tell me
> if it works for you

Right, the patch below works in my setup as well (until link-add-vxlan,
that is ;) )

Thanks,
Florian
