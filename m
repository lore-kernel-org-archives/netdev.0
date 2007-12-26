From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: Re: [patch 7/7] netxen: fix byte-swapping in tx and rx
Date: Wed, 26 Dec 2007 15:29:22 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0712261525490.23059@dut46.unminc.com>
References: <20071226182352.704678179@netxen.com> <20071226182928.425988922@netxen.com>
 <20071226223803.GE27894@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, jeff@garzik.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:40197 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751220AbXLZXZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2007 18:25:47 -0500
In-Reply-To: <20071226223803.GE27894@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I agree for tx desc, the compiler would optimize.

But for rx (status) desc, I didn't like multiple le64_to_cpu() 
for extracting various fields out of same status dword.

-Dhananjay

On Wed, 26 Dec 2007, Al Viro wrote:

> On Wed, Dec 26, 2007 at 10:23:59AM -0800, dhananjay@netxen.com wrote:
> > This cleans up some unnecessary byte-swapping while setting up tx and
> > interpreting rx desc. The 64 bit rx status data should be converted
> > to host endian format only once and the macros just need to extract
> > bitfields.
>  
> > -	(cmd_desc)->flags_opcode |= cpu_to_le16((val) & 0x7f))
> > +	((cmd_desc)->flags_opcode &= ~(0x7f), \
> > +	(cmd_desc)->flags_opcode |= (val) & 0x7f)
> >  #define netxen_set_cmd_desc_opcode(cmd_desc, val)	\
> > -	((cmd_desc)->flags_opcode &= ~cpu_to_le16(0x3f<<7), \
> > -	(cmd_desc)->flags_opcode |= cpu_to_le16(((val & 0x3f)<<7)))
> > +	((cmd_desc)->flags_opcode &= ~(0x3f<<7), \
> > +	(cmd_desc)->flags_opcode |= ((val) & 0x3f) << 7)
> 
> _oh_?
> 
> That's actually a pessimisation and I'd rather see that conversion in
> place gone - the thing will be less brittle that way.
> 
> BTW, note that cpu_to_le16() et.al. get evaluated by compiler when the
> argument is constant.
> 
