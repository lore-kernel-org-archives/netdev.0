From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] AF_PACKET: Fix PACKET_MMAP on 64-bit kernel/32-bit user
 systems
Date: Mon, 10 Aug 2009 19:17:06 +0200
Message-ID: <4A805612.5080709@trash.net>
References: <20090810130359.p2hixk2eoow8kwg8@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cndougla@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38932 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932349AbZHJRRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 13:17:10 -0400
In-Reply-To: <20090810130359.p2hixk2eoow8kwg8@imap.linux.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cndougla@linux.vnet.ibm.com wrote:
> PACKET_MMAP sets up a ring buffer at a memory location so that kernel
> and user space can read from it without extra overhead. However, the
> data is written with a header, struct tpacket_hdr, which begins with an
> unsigned long field, tp_status. This means in a split 64-bit/32-bit
> environment the kernel- and user-space reads from the mmap'd region will
> be different, since in kernel-space the field is 64-bit while in
> user-space the field is 32-bit.
> 
> The following patch makes the size of the structure constant by changing
> the tp_status field to 32-bits. It does not appear to need 64-bits,
> since only 4-bits are actually used throughout the AF_PACKET code.
> 
> Signed-off-by: Chase Douglas <cndougla@linux.vnet.ibm.com>
> --- a/include/linux/if_packet.h   2009-08-10 16:53:11.000000000 +0000
> +++ b/include/linux/if_packet.h   2009-08-10 16:53:28.000000000 +0000
> @@ -65,7 +65,7 @@ struct tpacket_auxdata
> 
>  struct tpacket_hdr
>  {
> -       unsigned long   tp_status;
> +       unsigned int    tp_status;

This changes the layout on 64 bit and thus breaks compatibility.
The tpacket2_hdr doesn't suffer from this problem.
