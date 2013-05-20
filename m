From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next v3] MPLS: Add limited GSO support
Date: Mon, 20 May 2013 12:20:49 +0900
Message-ID: <20130520032049.GG16811@verge.net.au>
References: <1368773452-32310-1-git-send-email-horms@verge.net.au>
 <CAEP_g=9JMk92eMaGrFs6pZv6AejcxfPSmOSXYi_UKrtZj3LwJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Maciej =?utf-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43953 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755255Ab3ETDUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 May 2013 23:20:53 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=9JMk92eMaGrFs6pZv6AejcxfPSmOSXYi_UKrtZj3LwJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 17, 2013 at 02:42:01PM -0700, Jesse Gross wrote:
> On Thu, May 16, 2013 at 11:50 PM, Simon Horman <horms@verge.net.au> wrote:
> > * Set skb->mac_len and skb->network_header to correspond to the
> >   end of the L3 header, including the MPLS label stack.
> 
> I believe that the treatment of skb->mac_len is different from what
> you are proposing in the OVS patch. I think this is because there is a
> call to skb_reset_mac_len() in __skb_gso_segment() but it is somewhat
> confusing. The GSO code is moving away from being able to reset all
> header pointers and reparse the packet (obviously that's not possible
> in the case of MPLS) so maybe we can just remove that call.

I agree that is likely. I will see about making it so.

> 
> > A new NETIF_F_GRE_GSO feature is added for devices which support
> > hardware MPLS GSO offload.  Currently no devices support this
> > and MPLS GSO always falls back to software.
> 
> I assume that this is supposed to refer to MPLS and not GRE.

Sorry about that, yes, I meant to type MPLS.
