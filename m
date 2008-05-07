From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: State of TCP segmentation offload to NIC in linux
Date: Wed, 7 May 2008 15:23:06 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290509D672@orsmsx414.amr.corp.intel.com>
References: <49c0ff980805011056q25d24616vf4cea6d8b387b717@mail.gmail.com> <D5C1322C3E673F459512FB59E0DDC3290501C9EA@orsmsx414.amr.corp.intel.com> <49c0ff980805071426h54073ddcw89ebe37a3d4e95b4@mail.gmail.com> <20080507215105.GB13470@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Ben Hutchings" <bhutchings@solarflare.com>,
	"prodyut hazarika" <prodyuth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6011 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933436AbYEGWXG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 18:23:06 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080507215105.GB13470@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > The IP layer does not need to be bypassed.  The TCP layer 
> will set 
> > > the proper headers for TSO to work properly and continue 
> sending the 
> > > skb down the stack.  IP will not fragment a packet on transmit.
> > 
> > Which flag/header does the TCP layer set to indicate to IP that it 
> > should not fragment a 64K segment, but rather offload the whole 
> > segment to NIC?
> 
> It sets skb_shinfo(skb)->gso_size to the desired segment size.
> 
> > I tried to look at the TCP code in linux stack, but could 
> not figure 
> > the flag or the logic that sets the flag/header you 
> mentioned. The NIC 
> > driver must indicate that it is capable of doing TSO by setting 
> > NETIF_F_TSO flag, but NETIF_F_TSO capability is not checked 
> in IP/TCP 
> > layer.
>  
> It's checked using sk_can_gso() (defined in <net/sock.h>) 
> which calls net_gso_ok() (defined in <linux/netdevice.h>).

To add: the flag that sk_can_gso() checks is set on the socket creation,
based on the underlying netdevice's TSO capabilities.  There are a bunch
of flags in the sk struct that get set on TCP socket creation that are
then used elsewhere in the TCP stack.

Cheers,
-PJ
