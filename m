From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH 3/5] qlge: bugfix: Fix endian issue regarding shadow registers.
Date: Wed, 24 Dec 2008 13:29:03 -0800
Message-ID: <20081224212903.GA16018@susedev.qlogic.org>
References: <20081224181834.GA15470@susedev.qlogic.org> <1230142896-15533-3-git-send-email-ron.mercer@qlogic.com> <1230143731.3070.2.camel@achroite> <20081224211521.GA25617@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:43540 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbYLXV3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 16:29:05 -0500
Content-Disposition: inline
In-Reply-To: <20081224211521.GA25617@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 24, 2008 at 01:15:21PM -0800, Christoph Hellwig wrote:
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

Yes, .prod_idx_sh_reg should be an __le32 *, but the volatile modifier 
was used since the memory location is modified by the chip and read by 
the driver.  Isn't that a case where it should be used?

> 
> And please verify the whole driver for endianess issues using sparse
> while you're at it...

Will do...


