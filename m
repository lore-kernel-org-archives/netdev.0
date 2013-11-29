From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] Should skb->csum include 8021Q header for
 CHECKSUM_COMPLETE && NETIF_F_HW_VLAN_CTAG_RX
Date: Fri, 29 Nov 2013 11:08:22 -0800
Message-ID: <20131129110822.6e4cf256@nehalam.linuxnetplumber.net>
References: <20131129132819.GA9176@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:54675 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276Ab3K2TI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 14:08:26 -0500
Received: by mail-pb0-f42.google.com with SMTP id uo5so15003648pbc.29
        for <netdev@vger.kernel.org>; Fri, 29 Nov 2013 11:08:25 -0800 (PST)
In-Reply-To: <20131129132819.GA9176@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Nov 2013 13:28:19 +0000
Thomas Graf <tgraf@suug.ch> wrote:

> Hi
> 
> Given CHECKSUM_COMPLETE, is skb->csum supposed to include the
> checksum of the VLAN header if the header was stripped by the
> NIC?
> 
> The answer is clear for non accelerated VLAN: it covers all of
> the packet without ethernet CRC.
> 
> For the accelerated path the answer is less clear after staring
> at drivers. The stack currently only fixes the csum for the
> software path.
> 
> We are seeing hw csum failure warnings for drivers like enic if
> OVS pops a VLAN header that was previously stripped  in hardware.
> Should we force CHECKSUM_NONE like VXLAN does or are all drivers
> guaranteed to include VLAN bits for CHECK_COMPLETE regardless of
> acceleration?
> 
> Best,
> Thomas
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Most hardware is smart enough that if it strips the VLAN header,
it does not include it in the checksum.
