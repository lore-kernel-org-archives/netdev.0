From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Add firmware label support to iproute2
Date: Wed, 18 Aug 2010 14:41:24 -0700
Message-ID: <20100818144124.33a72453@nehalam>
References: <20100812173537.GA29784@auslistsprd01.us.dell.com>
	<20100812141240.417949e2@s6510>
	<EDA0A4495861324DA2618B4C45DCB3EE612E34@blrx3m08.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <Matt_Domsch@Dell.com>,
	<Charles_Rose@Dell.com>, <Jordan_Hargrave@Dell.com>
To: <Narendra_K@Dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42176 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754168Ab0HRVl1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Aug 2010 17:41:27 -0400
In-Reply-To: <EDA0A4495861324DA2618B4C45DCB3EE612E34@blrx3m08.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Aug 2010 18:06:26 +0530
<Narendra_K@Dell.com> wrote:

> > -----Original Message-----
> > From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> > Sent: Thursday, August 12, 2010 11:43 PM
> > To: K, Narendra
> > Cc: netdev@vger.kernel.org; Domsch, Matt; Rose, Charles; Hargrave,
> > Jordan
> > Subject: Re: [PATCH] Add firmware label support to iproute2
> > 
> > On Thu, 12 Aug 2010 12:35:37 -0500
> > Narendra K <Narendra_K@dell.com> wrote:
> > 
> > > +#ifndef LIBNETDEVNAME_PRESENT
> > >  			filter_dev = *argv;
> > > +#else
> > > +			if (netdev_alias_to_kernelname(*argv,
> kernel_name) <
> > 0)
> > > +				show_firmware_alias_usage(*argv);
> > > +			filter_dev = kernel_name;
> > > +#endif
> > >  		}
> > 
> > like the kernel, I don't like ifdef cases in main code.
> > You should put in stub inline that returns appropriate error.
> > 
> 
> Stephen,
> 
> Thanks for the suggestions. I will rework the patch and send a revised
> version soon.
> 
> > What happens if alias matches existing interface name?
> 
> If the user inputs an existing 'ethN' name, the function
> 'netdev_alias_to_kernelaname' will return it as it is. If the user
> inputs 'Embedded NIC N', then the function would do a sysfs lookup and
> return the corresponding 'ethN' name.

The netdev_alias_to_kernelname should only happen after normal lookup failed.
Also how does ifindex to name mapping work?

-- 
