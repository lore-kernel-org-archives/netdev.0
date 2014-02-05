From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net:cpsw: Pass unhandled ioctl's on to generic phy ioctl
Date: Wed, 5 Feb 2014 08:12:51 +0100
Message-ID: <20140205071250.GA4071@netboy>
References: <1391500242-10554-1-git-send-email-stefan.sorensen@spectralink.com>
 <1391511050.3003.21.camel@deadeye.wl.decadent.org.uk>
 <1391526492.7871.8.camel@e37108.spectralink.com>
 <1391550719.3003.33.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-1?B?U/hyZW5zZW4s?= Stefan
	<Stefan.Sorensen@spectralink.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mugunthanvnm@ti.com" <mugunthanvnm@ti.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:36667 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932072AbaBEHM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 02:12:56 -0500
Received: by mail-ea0-f179.google.com with SMTP id q10so939ead.10
        for <netdev@vger.kernel.org>; Tue, 04 Feb 2014 23:12:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1391550719.3003.33.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 04, 2014 at 09:51:59PM +0000, Ben Hutchings wrote:
> 
> Right.  If all versions of CPSW include hardware timestamping then
> bother with PHY timestamping at all?  And why make CONFIG_TI_CPTS
> configurable?

On the one hand, PHY time stamping is more accurate and offers
synchronization performance that is measurably better than MAC time
stamping. On the other hand, when using a MAC the CPU usually has much
more direct access to the clock (for example, direct register access
or PCIe, versus MDIO).

I once worked on a project in which it was planned to have both kinds
of hardware in the design, in order to keep our options open in the
face of fluid requirements. So I think you can expect to see such
combinations in the wild, especially in the embedded area.

We cannot reasonably support both types in the kernel at the same
time, and so it makes sense to have compile time options in MAC
drivers to disable time stamping.

Thanks,
Richard
