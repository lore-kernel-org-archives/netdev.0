From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [PATCH 2/2] [POWERPC] Fix region size check in mpc5200 FEC driver
Date: Thu, 1 Nov 2007 12:25:36 -0600
Message-ID: <fa686aa40711011125w4df3b1b9r1693bdfec84dd281@mail.gmail.com>
References: <20071101142005.7620.54250.stgit@trillian.cg.shawcable.net>
	 <20071101142235.7620.36853.stgit@trillian.cg.shawcable.net>
	 <200711011913.55525.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, domen.puncer@telargo.com
To: "Ingo Oeser" <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.191]:48439 "EHLO
	rn-out-0102.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751353AbXKASZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 14:25:38 -0400
Received: by rn-out-0102.google.com with SMTP id s46so716400rnb
        for <netdev@vger.kernel.org>; Thu, 01 Nov 2007 11:25:37 -0700 (PDT)
In-Reply-To: <200711011913.55525.netdev@axxeo.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/1/07, Ingo Oeser <netdev@axxeo.de> wrote:
> Hi Grant,
>
> Grant Likely schrieb:
> > From: Grant Likely <grant.likely@secretlab.ca>
> >
> > Driver shouldn't complain if the register range is larger than what
> > it expects.  This works around failures with some device trees.
> >
>
> But maybe the firmware guys like to know about it?
> May I suggest putting this in front of the other check?
>
> if ((mem.end - mem.start + 1) > sizeof(struct mpc52xx_fec)) {
>                 printk(KERN_DEBUG DRIVER_NAME
>                         " - gratious resource size (%lx > %x), check mpc52xx_devices.c\n",
>                         (unsigned long)(mem.end - mem.start + 1), sizeof(struct mpc52xx_fec));

Personally, I'm not concerned about it.  Even if the device tree says
the range is larger than what the driver knows about it is not
technically an error. If a new version of the chip appears that is
compatible, but defines a larger register range with extra feature
registers, then this message would be erroneously printed.  Finally,
depending on how you read the mpc5200 user guild, it can be 100% valid
to specify the reg size as 0x800 instead of 0x400.

Cheers,
g.

-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
grant.likely@secretlab.ca
(403) 399-0195
