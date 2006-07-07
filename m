From: "Dmitry Torokhov" <dmitry.torokhov@gmail.com>
Subject: Re: [patch 8/9] smsc-ircc2: fix section reference mismatches
Date: Fri, 7 Jul 2006 15:53:25 -0400
Message-ID: <d120d5000607071253ge7d8ae1u558dd236e4275dd2@mail.gmail.com>
References: <200607070658.k676wRh5030383@shell0.pdx.osdl.net>
	 <44AE99B0.6040508@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:37146 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S932298AbWGGTx0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 15:53:26 -0400
Received: by ug-out-1314.google.com with SMTP id u40so313880ugc
        for <netdev@vger.kernel.org>; Fri, 07 Jul 2006 12:53:25 -0700 (PDT)
To: "Jeff Garzik" <jeff@garzik.org>
In-Reply-To: <44AE99B0.6040508@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/7/06, Jeff Garzik <jeff@garzik.org> wrote:
> akpm@osdl.org wrote:
> > From: Dmitry Torokhov <dtor@insightbb.com>
> >
> > subsystem_configurations array is only used by an __init function,
> > therefore it should be marked __initdata, not __devinitdata.
> >
> > Signed-off-by: Dmitry Torokhov <dtor@mail.ru>
> > Signed-off-by: Andrew Morton <akpm@osdl.org>
> > ---
> >
> >  drivers/net/irda/smsc-ircc2.c |    2 +-
> >  1 files changed, 1 insertion(+), 1 deletion(-)
> >
> > diff -puN drivers/net/irda/smsc-ircc2.c~smsc-ircc2-fix-section-reference-mismatches drivers/net/irda/smsc-ircc2.c
> > --- a/drivers/net/irda/smsc-ircc2.c~smsc-ircc2-fix-section-reference-mismatches
> > +++ a/drivers/net/irda/smsc-ircc2.c
> > @@ -2353,7 +2353,7 @@ static int __init smsc_superio_lpc(unsig
> >  #ifdef CONFIG_PCI
> >  #define PCIID_VENDOR_INTEL 0x8086
> >  #define PCIID_VENDOR_ALI 0x10b9
> > -static struct smsc_ircc_subsystem_configuration subsystem_configurations[] __devinitdata = {
> > +static struct smsc_ircc_subsystem_configuration subsystem_configurations[] __initdata = {
>
> Are you sure this fully solves the problem?
>

I think so, at least I see no more warnigns...

> It seems like the functions referenced inside this are inappropriately
> marked as well...
>

subsystem_configurations is only used from
smsc_ircc_preconfigure_subsystems(), which is called from
smsc_ircc_init(). Both of these are __init. All methods in
subsystem_configurations are marked as __init as well. Seems logical
that the strcture should be marked __initdata.

-- 
Dmitry
