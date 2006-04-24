From: "Ananda Raju" <ananda.raju@neterion.com>
Subject: RE: [patch 2/5] s2io driver updates
Date: Mon, 24 Apr 2006 10:39:52 -0700
Message-ID: <200604241740.k3OHepDr023452@guinness.s2io.com>
References: <20060424102203.3cb5e29b@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <jgarzik@pobox.com>, <netdev@vger.kernel.org>,
	<leonid.grossman@neterion.com>, <ravinandan.arakali@neterion.com>,
	<rapuru.sriram@neterion.com>, <alicia.pena@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:36236 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1751053AbWDXRk7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Apr 2006 13:40:59 -0400
To: "'Stephen Hemminger'" <shemminger@osdl.org>,
	"'Francois Romieu'" <romieu@fr.zoreil.com>
In-Reply-To: <20060424102203.3cb5e29b@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, 

Currently the only way we can differentiate between copper CX4 transponder
adapters from optical transponder adapters is by reading the product name
string in vpd. 

Actually we added the VPD read function for identifying CX4 adapter. While
submitting the patch the CX4 changes went in patch 3 and reading of vpd went
in patch 2. 

Also we have one more product Xframe-E which is a PCIe adapter. This also
has same device ID of Xframe-II PCI-X adapter. As we have multiple product
with same Device_ID and only way to differentiate between them is through
VPD string we are reading VPD string in driver. 

Thanks 
Ananda. 

-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@osdl.org] 
Sent: Monday, April 24, 2006 10:22 AM
To: Francois Romieu
Cc: Ananda Raju; jgarzik@pobox.com; netdev@vger.kernel.org;
leonid.grossman@neterion.com; ravinandan.arakali@neterion.com;
rapuru.sriram@neterion.com; alicia.pena@neterion.com
Subject: Re: [patch 2/5] s2io driver updates

On Sat, 22 Apr 2006 11:28:02 +0200
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Ananda Raju <Ananda.Raju@neterion.com> :
> [...]
> > Signed-off-by: Ananda Raju <ananda.raju@neterion.com>
> > ---
> > diff -upNr perf_fixes/drivers/net/s2io.c
dmesg_param_fixes/drivers/net/s2io.c
> > --- perf_fixes/drivers/net/s2io.c	2006-04-13 08:02:56.000000000 -0700
> > +++ dmesg_param_fixes/drivers/net/s2io.c	2006-04-13
09:08:22.000000000 -0700
> [...]
> > @@ -4626,6 +4633,45 @@ static int write_eeprom(nic_t * sp, int 
> >  	return ret;
> >  }
> >  
> > +static void s2io_vpd_read(nic_t *nic)
> > +{
> > +	u8 vpd_data[256],data;
> 
> You may consider removing vpd_data from the stack and kmallocing it.
> 

Since there lsvpd tool doesn't in user space, why add more kernel code
to do it?  Adding more code to just print prettier console log's is bogus.

