From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [patch 7/7] netxen: fix byte-swapping in tx and rx
Date: Wed, 26 Dec 2007 22:38:03 +0000
Message-ID: <20071226223803.GE27894@ZenIV.linux.org.uk>
References: <20071226182352.704678179@netxen.com> <20071226182928.425988922@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:48587 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605AbXLZWiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2007 17:38:06 -0500
Content-Disposition: inline
In-Reply-To: <20071226182928.425988922@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 26, 2007 at 10:23:59AM -0800, dhananjay@netxen.com wrote:
> This cleans up some unnecessary byte-swapping while setting up tx and
> interpreting rx desc. The 64 bit rx status data should be converted
> to host endian format only once and the macros just need to extract
> bitfields.
 
> -	(cmd_desc)->flags_opcode |= cpu_to_le16((val) & 0x7f))
> +	((cmd_desc)->flags_opcode &= ~(0x7f), \
> +	(cmd_desc)->flags_opcode |= (val) & 0x7f)
>  #define netxen_set_cmd_desc_opcode(cmd_desc, val)	\
> -	((cmd_desc)->flags_opcode &= ~cpu_to_le16(0x3f<<7), \
> -	(cmd_desc)->flags_opcode |= cpu_to_le16(((val & 0x3f)<<7)))
> +	((cmd_desc)->flags_opcode &= ~(0x3f<<7), \
> +	(cmd_desc)->flags_opcode |= ((val) & 0x3f) << 7)

_oh_?

That's actually a pessimisation and I'd rather see that conversion in
place gone - the thing will be less brittle that way.

BTW, note that cpu_to_le16() et.al. get evaluated by compiler when the
argument is constant.
