From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH 3/5] qlge: bugfix: Fix endian issue regarding shadow
 registers.
Date: Wed, 24 Dec 2008 13:57:07 -0800
Message-ID: <1230155827.1447.10.camel@brick>
References: <20081224181834.GA15470@susedev.qlogic.org>
	 <1230142896-15533-3-git-send-email-ron.mercer@qlogic.com>
	 <1230143731.3070.2.camel@achroite>  <20081224211521.GA25617@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Ron Mercer <ron.mercer@qlogic.com>, netdev@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:38458 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbYLXV5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 16:57:21 -0500
Received: by wf-out-1314.google.com with SMTP id 27so3340074wfd.4
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2008 13:57:20 -0800 (PST)
In-Reply-To: <20081224211521.GA25617@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-12-24 at 16:15 -0500, Christoph Hellwig wrote:
> On Wed, Dec 24, 2008 at 06:35:31PM +0000, Ben Hutchings wrote:
> > > -static inline unsigned int ql_read_sh_reg(const volatile void  *addr)
> > > +static inline u32 ql_read_sh_reg(const volatile void  *addr)
> > >  {
> > > -	return *(volatile unsigned int __force *)addr;
> > > +	return le32_to_cpu(*(volatile unsigned int __force *)addr);
> > 
> > I think that should be:
> > 	???return le32_to_cpu(*(const volatile __le32 *)addr);
> 
> No.  It needs more love than that.
> 
> ql_read_sh_reg is only used to access .prod_idx_sh_reg in the rx_ring
> structure, which is an offset from the .rx_ring_shadow_reg_area member.
> So instead of all this werid casting .prod_idx_sh_reg should simply
> be a __le32 pointer, whithout volatile and the other mess, and then
> you can use le32_to_cpu directly and kill the helper.
> 
> And please verify the whole driver for endianess issues using sparse
> while you're at it...

I've already deleted the patches from my inbox, but if you send them
again off-list I'll have a look as well.

Harvey

