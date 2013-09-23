From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool] sfc: Add support for EF10 registers
Date: Mon, 23 Sep 2013 17:52:02 +0100
Message-ID: <1379955122.2485.47.camel@bwh-desktop.uk.level5networks.com>
References: <1379952298.2485.35.camel@bwh-desktop.uk.level5networks.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7354@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:36166 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555Ab3IWQwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 12:52:07 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7354@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-23 at 17:14 +0100, David Laight wrote:
> >  struct efx_nic_reg_field {
> >  	const char *name;
> >  	u32 lbn:7, width:8;
> > -	u32 min_revision:2, max_revision:2;
> > +	u32 min_revision:3, max_revision:3;
> >  };
> ...
> >  struct efx_nic_reg_table {
> >  	const char *name;
> >  	const struct efx_nic_reg_field *fields;
> >  	u32 field_count:7;
> > -	u32 min_revision:2, max_revision:2;
> > +	u32 min_revision:3, max_revision:3;
> >  	u32 step:6, rows:21;
> >  };
> 
> These bitfields look rather pointless.
> AFACT the size of the structures wouldn't change if the fields
> were just u8 or u32. The code would be a lot smaller.

The definition of struct efx_nic_reg_table is based on the structure of
the same name in the driver, where I think the bitfields do provide a
net saving (but I'm not sure).  efx_nic_reg_field is specific to ethtool
and the bitfields there are indeed pointless.

Changing to u8 and u32 as appropriate saved about 200 bytes on an x86_64
build here.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
