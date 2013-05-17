From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v3] MPLS: Add limited GSO support
Date: Fri, 17 May 2013 14:42:01 -0700
Message-ID: <CAEP_g=9JMk92eMaGrFs6pZv6AejcxfPSmOSXYi_UKrtZj3LwJA@mail.gmail.com>
References: <1368773452-32310-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:60124 "HELO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757285Ab3EQVmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 17:42:21 -0400
Received: by mail-ie0-f175.google.com with SMTP id s9so10255530iec.20
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 14:42:21 -0700 (PDT)
In-Reply-To: <1368773452-32310-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 16, 2013 at 11:50 PM, Simon Horman <horms@verge.net.au> wrote:
> * Set skb->mac_len and skb->network_header to correspond to the
>   end of the L3 header, including the MPLS label stack.

I believe that the treatment of skb->mac_len is different from what
you are proposing in the OVS patch. I think this is because there is a
call to skb_reset_mac_len() in __skb_gso_segment() but it is somewhat
confusing. The GSO code is moving away from being able to reset all
header pointers and reparse the packet (obviously that's not possible
in the case of MPLS) so maybe we can just remove that call.

> A new NETIF_F_GRE_GSO feature is added for devices which support
> hardware MPLS GSO offload.  Currently no devices support this
> and MPLS GSO always falls back to software.

I assume that this is supposed to refer to MPLS and not GRE.
