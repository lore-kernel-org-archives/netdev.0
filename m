From: "Ronciak, John" <john.ronciak@intel.com>
Subject: RE: [PATCH] abysmal e1000 performance (DITR)
Date: Fri, 27 Aug 2004 14:49:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <468F3FDA28AA87429AD807992E22D07EAF76C0@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <hadi@cyberus.ca>, "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        <netdev@oss.sgi.com>, "Feldman, Scott" <scott.feldman@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: <tharbaugh@lnxi.com>, "Jeff Garzik" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal, Thayne,

I've asked Jeff to go ahead and apply this patch as a way around this
for now.  We would liketo see the DITR stay but now have this
performacne problem so we don't want to rip it out.  We do however need
a test case to replicate this as we have not been seeing it in our
testing.  Please get us those case that break things.  We'll have a
better solution longer term based on the test cases (as well as the ones
we normally use of course).

Thanks.

Cheers,
John


> -----Original Message-----
> From: netdev-bounce@oss.sgi.com 
> [mailto:netdev-bounce@oss.sgi.com] On Behalf Of Thayne Harbaugh
> Sent: Thursday, August 26, 2004 2:29 PM
> To: Jeff Garzik
> Cc: hadi@cyberus.ca; Venkatesan, Ganesh; netdev@oss.sgi.com; 
> Feldman, Scott; Brandeburg, Jesse
> Subject: Re: [PATCH] abysmal e1000 performance (DITR)
> 
> 
> On Thu, 2004-08-26 at 16:26 -0400, Jeff Garzik wrote:
> > Thayne Harbaugh wrote:
> > > On Thu, 2004-08-26 at 13:55 -0400, jamal wrote:
> > > 
> > >>Ganesh,
> > >>
> > >>Can you please make this feature off by default and perhaps
> > >>accesible via ethtool for peopel who want to turn it on.
> > >>I just wasted a few hours and was bitten by this performance-wise.
> > >>Please consider disabling it.
> > > 
> > > 
> > > This is a *horrible* problem.  Even though it's fixable 
> by passing a
> > > module parameter, the default bites those that *know* 
> about it.  We have
> > > had customers bitten by this and customers that have insisted in
> > > swapping all the NICs in a cluster to Broadcom TG3 NICs.
> > > 
> > > It's a black eye for Intel and a loss of business - 
> that's the opinion
> > > of our customers.
> > 
> > 
> > If it's so bad we should disable it by default, either via 
> the module 
> > parameter or via a kernel CONFIG_xxx option.
> 
> Yes, it is so bad.  The dynamic interrupt setting should be deprecated
> by the use of NAPI.
> 
> This is a simple way to disable it, yet still keep the code so that
> someone can enable it if they really wanted it.  I, however, 
> would just
> as soon see all of the DITR code ripped out.
> 
> There are other ways that might be better for dealing with 
> it, yet still
> keeping the DITR code viable.
> 
> --- drivers/net/e1000/e1000_param.c.broken_ditr 2004-08-26 
> 15:40:34.436456736 -0600
> +++ drivers/net/e1000/e1000_param.c     2004-08-26 
> 15:49:07.186506880 -0600
> @@ -212,7 +212,7 @@
>  #define MAX_TXABSDELAY            0xFFFF
>  #define MIN_TXABSDELAY                 0
>   
> -#define DEFAULT_ITR                    1
> +#define DEFAULT_ITR                 8000
>  #define MAX_ITR                   100000
>  #define MIN_ITR                      100
>   
> 
> 
> 
> 
