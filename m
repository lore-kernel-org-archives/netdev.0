From: "Ronciak, John" <john.ronciak@intel.com>
Subject: RE: [PATCH] abysmal e1000 performance (DITR)
Date: Fri, 27 Aug 2004 15:41:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <468F3FDA28AA87429AD807992E22D07EAF76C5@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>, <hadi@cyberus.ca>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        <netdev@oss.sgi.com>, "Feldman, Scott" <scott.feldman@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: <tharbaugh@lnxi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thayne,

I can't speak to what happened previously, only what's going on now.
You need to be careful about basing any tuning on any one single test.
For each one of these test you find that have performance problems I can
show you where it works just fine and most cases works better.  So let
be careful about making judgements like this.

We are going to look at this and make some changes based on what we
find.  I already said that we probably won't be ripping out the DITR as
some people really make a lot of use out of it.  It may be off by
default or have some default setting which doesn't hurt test cases.
Since Netpipe is a relatively unused test for performance (not really
it's purpose, it was developed to find "holes" in internet packets
lengths), it's not part of our normal testing.

Like I said, we are looking at it and will come up with a more robust
solution.

Cheers,
John


> -----Original Message-----
> From: Thayne Harbaugh [mailto:tharbaugh@lnxi.com] 
> Sent: Friday, August 27, 2004 3:05 PM
> To: Ronciak, John
> Cc: Jeff Garzik; hadi@cyberus.ca; Venkatesan, Ganesh; 
> netdev@oss.sgi.com; Feldman, Scott; Brandeburg, Jesse
> Subject: RE: [PATCH] abysmal e1000 performance (DITR)
> 
> 
> On Fri, 2004-08-27 at 14:49 -0700, Ronciak, John wrote:
> > Jamal, Thayne,
> > 
> > I've asked Jeff to go ahead and apply this patch as a way 
> around this
> > for now.  We would liketo see the DITR stay but now have this
> > performacne problem so we don't want to rip it out.  We do 
> however need
> > a test case to replicate this as we have not been seeing it in our
> > testing.  Please get us those case that break things.  We'll have a
> > better solution longer term based on the test cases (as 
> well as the ones
> > we normally use of course).
> 
> Attached is an email that I sent out 2004 May 25.  The email is very
> detailed about what the problem is, how to test it, and an initial
> patch.  The email was sent to several addresses at Intel.  I 
> later sent
> it to lkml and netdev.
> 
> There was almost no response at the time.  The best reply that I
> received from Intel was that the DITR was put in and calibrated
> according to a marketing benchmark program and that it wouldn't be
> changed even though tests (and customers) showed that the performance
> was *abysmal*.  It's also a big question what role DITR plays when it
> seems deprecated by NAPI.
> 
> The response was disappointing.  I'm now wondering why this has now
> become interesting and the thread has resumed.  What's 
> changed?  How did
> this catch someone's attention?  What can I do next time 
> (hopefully that
> won't happen) so that people *do* take interest.
> 
> > 
> > > -----Original Message-----
> > > From: netdev-bounce@oss.sgi.com 
> > > [mailto:netdev-bounce@oss.sgi.com] On Behalf Of Thayne Harbaugh
> > > Sent: Thursday, August 26, 2004 2:29 PM
> > > To: Jeff Garzik
> > > Cc: hadi@cyberus.ca; Venkatesan, Ganesh; netdev@oss.sgi.com; 
> > > Feldman, Scott; Brandeburg, Jesse
> > > Subject: Re: [PATCH] abysmal e1000 performance (DITR)
> > > 
> > > 
> > > On Thu, 2004-08-26 at 16:26 -0400, Jeff Garzik wrote:
> > > > Thayne Harbaugh wrote:
> > > > > On Thu, 2004-08-26 at 13:55 -0400, jamal wrote:
> > > > > 
> > > > >>Ganesh,
> > > > >>
> > > > >>Can you please make this feature off by default and perhaps
> > > > >>accesible via ethtool for peopel who want to turn it on.
> > > > >>I just wasted a few hours and was bitten by this 
> performance-wise.
> > > > >>Please consider disabling it.
> > > > > 
> > > > > 
> > > > > This is a *horrible* problem.  Even though it's fixable 
> > > by passing a
> > > > > module parameter, the default bites those that *know* 
> > > about it.  We have
> > > > > had customers bitten by this and customers that have 
> insisted in
> > > > > swapping all the NICs in a cluster to Broadcom TG3 NICs.
> > > > > 
> > > > > It's a black eye for Intel and a loss of business - 
> > > that's the opinion
> > > > > of our customers.
> > > > 
> > > > 
> > > > If it's so bad we should disable it by default, either via 
> > > the module 
> > > > parameter or via a kernel CONFIG_xxx option.
> > > 
> > > Yes, it is so bad.  The dynamic interrupt setting should 
> be deprecated
> > > by the use of NAPI.
> > > 
> > > This is a simple way to disable it, yet still keep the 
> code so that
> > > someone can enable it if they really wanted it.  I, however, 
> > > would just
> > > as soon see all of the DITR code ripped out.
> > > 
> > > There are other ways that might be better for dealing with 
> > > it, yet still
> > > keeping the DITR code viable.
> > > 
> > > --- drivers/net/e1000/e1000_param.c.broken_ditr 2004-08-26 
> > > 15:40:34.436456736 -0600
> > > +++ drivers/net/e1000/e1000_param.c     2004-08-26 
> > > 15:49:07.186506880 -0600
> > > @@ -212,7 +212,7 @@
> > >  #define MAX_TXABSDELAY            0xFFFF
> > >  #define MIN_TXABSDELAY                 0
> > >   
> > > -#define DEFAULT_ITR                    1
> > > +#define DEFAULT_ITR                 8000
> > >  #define MAX_ITR                   100000
> > >  #define MIN_ITR                      100
> > >   
> > > 
> > > 
> > > 
> > > 
> 
