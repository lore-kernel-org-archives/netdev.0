From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: Re: [RFC] potential bugs in nexten
Date: Mon, 24 Dec 2007 17:04:39 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0712241653540.6128@dut46.unminc.com>
References: <E1J6X0S-0007Sb-AQ@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Al Viro <viro@ftp.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:51317 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750987AbXLYBBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 20:01:23 -0500
In-Reply-To: <E1J6X0S-0007Sb-AQ@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Probably I need to clean up much more junk like that from days before I 
took over. I recently cleaned up a bit of rx and tx code, which is more 
frequently executed.

The last one (byte swapping) is serious and I am gonna take care of that 
in next patch. 

Thanks,
-Dhananjay

On Sun, 23 Dec 2007, Al Viro wrote:

> 
> * what are default: doing in netxen_nic_hw_write_wx()/netxen_nic_hw_read_wx()?
> Unlike all other cases they do iomem->iomem copying and AFAICS they are never
> actually triggered.
> 
> * netxen_nic_flash_print() reads the entire user_info from card *in* *host-endian*,
> then uses user_info.serial_number[].
> 	a) do we need to read the rest?
> 	b) more interesting question, don't we need cpu_to_le32() here?  After
> all, that sucker is an array of char, so we want it in the same order regardless
> of the host...
> 
> * in netxen_nic_xmit_frame() we do
> 	hw->cmd_desc_head[saved_producer].flags_opcode =
> 		cpu_to_le16(hw->cmd_desc_head[saved_producer].flags_opcode);
> 	hw->cmd_desc_head[saved_producer].num_of_buffers_total_length =
> 	  cpu_to_le32(hw->cmd_desc_head[saved_producer].
> 			  num_of_buffers_total_length);
> Huh?  Everything that modifies either of those does so in little-endian already.
> This code appeared in commit 6c80b18df3537d1221ab34555c150bccbfd90260 (NetXen:
> Port swap feature for multi port cards); what's going on there?
> 
> 
