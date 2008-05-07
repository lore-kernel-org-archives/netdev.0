From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: State of TCP segmentation offload to NIC in linux
Date: Wed, 7 May 2008 22:51:07 +0100
Message-ID: <20080507215105.GB13470@solarflare.com>
References: <49c0ff980805011056q25d24616vf4cea6d8b387b717@mail.gmail.com> <D5C1322C3E673F459512FB59E0DDC3290501C9EA@orsmsx414.amr.corp.intel.com> <49c0ff980805071426h54073ddcw89ebe37a3d4e95b4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org
To: prodyut hazarika <prodyuth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:56720 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754770AbYEGVvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 17:51:16 -0400
Content-Disposition: inline
In-Reply-To: <49c0ff980805071426h54073ddcw89ebe37a3d4e95b4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

prodyut hazarika wrote:
> Thanks for your reply, Peter. I would appreciate if you could clarify
> little more.
> 
> 
> > The IP layer does not need to be bypassed.  The TCP layer will set the
> > proper headers for TSO to work properly and continue sending the skb
> > down the stack.  IP will not fragment a packet on transmit.
> 
> Which flag/header does the TCP layer set to indicate to IP that it
> should not fragment a 64K segment, but rather offload the whole
> segment to NIC?

It sets skb_shinfo(skb)->gso_size to the desired segment size.

> I tried to look at the TCP code in linux stack, but
> could not figure the flag or the logic that sets the flag/header you
> mentioned. The NIC driver must indicate that it is capable of doing
> TSO by setting NETIF_F_TSO flag, but NETIF_F_TSO capability is not
> checked in IP/TCP layer.
 
It's checked using sk_can_gso() (defined in <net/sock.h>) which
calls net_gso_ok() (defined in <linux/netdevice.h>).

> I would really appreciate if you could point me to the function in TCP
> code in linux.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
