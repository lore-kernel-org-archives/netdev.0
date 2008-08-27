From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH 2/6] [RFC] qlge: New Driver: Adding main driver file qlge_main.c.
Date: Wed, 27 Aug 2008 07:11:27 -0700
Message-ID: <20080827141127.GC31059@susedev.qlogic.org>
References: <20080822200906.GD2551@susedev.qlogic.org> <12194364662050-git-send-email-ron.mercer@qlogic.com> <20080826112420.GY7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:35204 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755717AbYH0OMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 10:12:13 -0400
Content-Disposition: inline
In-Reply-To: <20080826112420.GY7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 26, 2008 at 12:24:21PM +0100, Ben Hutchings wrote:

> > +static int ql_adapter_initialize(struct ql_adapter *qdev)
> > +{
> > +	u32 value, mask;
> > +	int i;
> > +	int status = 0;
> > +
> > +	/*
> > +	 * Set up the System register to halt on errors.
> > +	 */
> > +	value = SYS_EFE | SYS_FAE;
> > +	mask = value << 16;
> > +	ql_write32(qdev, SYS, mask | value);
> > +
> > +	/* Set the default queue. */
> > +	value = NIC_RCV_CFG_DFQ;
> > +	mask = NIC_RCV_CFG_DFQ_MASK;
> > +	ql_write32(qdev, NIC_RCV_CFG, (mask | value));
> > +
> > +	/* Set the MPI interrupt to enabled. */
> > +	ql_write32(qdev, INTR_MASK, (INTR_MASK_PI << 16) | INTR_MASK_PI);
> > +
> > +	/* Enable the function, set pagesize, enable error checking. */
> > +	value = FSC_FE | FSC_EPC_INBOUND | FSC_EPC_OUTBOUND | FSC_EC;
> > +
> > +	if (PAGE_SHIFT == 12)	/* 4k pages */
> > +		value |= FSC_VM_PAGE_4K;
> > +	else if (PAGE_SHIFT == 13)	/* 8k pages */
> > +		value |= FSC_VM_PAGE_8K;
> > +	else if (PAGE_SHIFT == 16)	/* 64k pages */
> > +		value |= FSC_VM_PAGE_64K;
> > +	else {
> > +		QPRINTK(IFUP, ERR, "Invalid page size of %d.\n",
> > +			1 << PAGE_SHIFT);
> 
> You can use
> 	BUILD_BUG_ON(PAGE_SHIFT != 12 && PAGE_SHIFT != 13 && PAGE_SHIFT != 16);
> to detect this problem at compile time.
> 
> Why doesn't this function do any cleanup in case of failure part way
> through?
> 
> [...]

Ben, I realized I did not completely answer your question here. 
The reason there is not cleanup when a failure occurs is because all that has been done is some chip
initialization.  If ql_adapter_initialize fails the calling function
will reset the chip and do the rest of the cleanup.

Thanks,
Ron
