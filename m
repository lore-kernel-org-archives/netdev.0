From: Thayne Harbaugh <tharbaugh@lnxi.com>
Subject: RE: [PATCH] abysmal e1000 performance (DITR)
Date: Fri, 27 Aug 2004 16:05:00 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093644300.20769.197.camel@tubarao>
References: <468F3FDA28AA87429AD807992E22D07EAF76C0@orsmsx408>
Reply-To: tharbaugh@lnxi.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-FHfNDUzLkv+fSdAPZ3F2"
Cc: Jeff Garzik <jgarzik@pobox.com>, hadi@cyberus.ca,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>, netdev@oss.sgi.com,
        "Feldman, Scott" <scott.feldman@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Ronciak, John" <john.ronciak@intel.com>
In-Reply-To: <468F3FDA28AA87429AD807992E22D07EAF76C0@orsmsx408>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-FHfNDUzLkv+fSdAPZ3F2
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2004-08-27 at 14:49 -0700, Ronciak, John wrote:
> Jamal, Thayne,
> 
> I've asked Jeff to go ahead and apply this patch as a way around this
> for now.  We would liketo see the DITR stay but now have this
> performacne problem so we don't want to rip it out.  We do however need
> a test case to replicate this as we have not been seeing it in our
> testing.  Please get us those case that break things.  We'll have a
> better solution longer term based on the test cases (as well as the ones
> we normally use of course).

Attached is an email that I sent out 2004 May 25.  The email is very
detailed about what the problem is, how to test it, and an initial
patch.  The email was sent to several addresses at Intel.  I later sent
it to lkml and netdev.

There was almost no response at the time.  The best reply that I
received from Intel was that the DITR was put in and calibrated
according to a marketing benchmark program and that it wouldn't be
changed even though tests (and customers) showed that the performance
was *abysmal*.  It's also a big question what role DITR plays when it
seems deprecated by NAPI.

The response was disappointing.  I'm now wondering why this has now
become interesting and the thread has resumed.  What's changed?  How did
this catch someone's attention?  What can I do next time (hopefully that
won't happen) so that people *do* take interest.

> 
> > -----Original Message-----
> > From: netdev-bounce@oss.sgi.com 
> > [mailto:netdev-bounce@oss.sgi.com] On Behalf Of Thayne Harbaugh
> > Sent: Thursday, August 26, 2004 2:29 PM
> > To: Jeff Garzik
> > Cc: hadi@cyberus.ca; Venkatesan, Ganesh; netdev@oss.sgi.com; 
> > Feldman, Scott; Brandeburg, Jesse
> > Subject: Re: [PATCH] abysmal e1000 performance (DITR)
> > 
> > 
> > On Thu, 2004-08-26 at 16:26 -0400, Jeff Garzik wrote:
> > > Thayne Harbaugh wrote:
> > > > On Thu, 2004-08-26 at 13:55 -0400, jamal wrote:
> > > > 
> > > >>Ganesh,
> > > >>
> > > >>Can you please make this feature off by default and perhaps
> > > >>accesible via ethtool for peopel who want to turn it on.
> > > >>I just wasted a few hours and was bitten by this performance-wise.
> > > >>Please consider disabling it.
> > > > 
> > > > 
> > > > This is a *horrible* problem.  Even though it's fixable 
> > by passing a
> > > > module parameter, the default bites those that *know* 
> > about it.  We have
> > > > had customers bitten by this and customers that have insisted in
> > > > swapping all the NICs in a cluster to Broadcom TG3 NICs.
> > > > 
> > > > It's a black eye for Intel and a loss of business - 
> > that's the opinion
> > > > of our customers.
> > > 
> > > 
> > > If it's so bad we should disable it by default, either via 
> > the module 
> > > parameter or via a kernel CONFIG_xxx option.
> > 
> > Yes, it is so bad.  The dynamic interrupt setting should be deprecated
> > by the use of NAPI.
> > 
> > This is a simple way to disable it, yet still keep the code so that
> > someone can enable it if they really wanted it.  I, however, 
> > would just
> > as soon see all of the DITR code ripped out.
> > 
> > There are other ways that might be better for dealing with 
> > it, yet still
> > keeping the DITR code viable.
> > 
> > --- drivers/net/e1000/e1000_param.c.broken_ditr 2004-08-26 
> > 15:40:34.436456736 -0600
> > +++ drivers/net/e1000/e1000_param.c     2004-08-26 
> > 15:49:07.186506880 -0600
> > @@ -212,7 +212,7 @@
> >  #define MAX_TXABSDELAY            0xFFFF
> >  #define MIN_TXABSDELAY                 0
> >   
> > -#define DEFAULT_ITR                    1
> > +#define DEFAULT_ITR                 8000
> >  #define MAX_ITR                   100000
> >  #define MIN_ITR                      100
> >   
> > 
> > 
> > 
> > 

--=-FHfNDUzLkv+fSdAPZ3F2
Content-Disposition: inline
Content-Description: Attached message - abysmal e1000 performance (DITR)
Content-Type: message/rfc822

Subject: abysmal e1000 performance (DITR)
From: Thayne Harbaugh <tharbaugh@lnxi.com>
Reply-To: tharbaugh@lnxi.com
To: linux-kernel@vger.kernel.org
Content-Type: text/plain
Organization: Linux Networx
Message-Id: <1085504557.30156.59.camel@tubarao>
Mime-Version: 1.0
X-Mailer: Ximian Evolution 1.4.6 (1.4.6-2) 
Date: Tue, 25 May 2004 11:02:37 -0600
Bcc: linux.nics@intel.com
X-Evolution-Transport: smtp://tharbaugh@ash.lnxi.com
X-Evolution-Account: tharbaugh@lnxi.com
X-Evolution-Fcc: file:///home/thayne/evolution/local/Sent
X-Evolution-Format: text/plain
Content-Transfer-Encoding: 7bit

The DITR (Dynamic Interrupt Throttle Rate) introduced in the 5.x version
of the e1000 driver can limit performance to less than 50% of expected.

I have two machines with secondary e1000 NICs directly connected (no
switch).  I run a test using Netpipe
(http://www.scl.ameslab.gov/netpipe/):

flu2:~ # /tmp/NPtcp -h 10.0.0.1
Send and receive buffers are 16384 and 87380 bytes
(A bug in Linux doubles the requested buffer sizes)
Now starting the main loop
  0:       1 bytes   4999 times -->      0.03 Mbps in     250.03 usec
  1:       2 bytes    399 times -->      0.06 Mbps in     250.02 usec
  2:       3 bytes    399 times -->      0.09 Mbps in     250.02 usec

(mostly uninteresting lines)

 70:   24573 bytes    121 times -->    380.39 Mbps in     492.85 usec
 71:   24576 bytes    135 times -->    380.43 Mbps in     492.86 usec
 72:   24579 bytes    135 times -->    380.49 Mbps in     492.84 usec
 73:   32765 bytes     67 times -->    341.32 Mbps in     732.39 usec
 74:   32768 bytes     68 times -->    341.37 Mbps in     732.35 usec
 75:   32771 bytes     68 times -->    341.41 Mbps in     732.33 usec
 76:   49149 bytes     68 times -->    437.02 Mbps in     858.04 usec
 77:   49152 bytes     77 times -->    451.39 Mbps in     830.77 usec
 78:   49155 bytes     80 times -->    499.57 Mbps in     750.69 usec

That's the best performance, but it drops back down.

 79:   65533 bytes     44 times -->    409.48 Mbps in    1221.00 usec
 80:   65536 bytes     40 times -->    409.42 Mbps in    1221.24 usec
 81:   65539 bytes     40 times -->    409.43 Mbps in    1221.28 usec

Not much different.

121: 8388605 bytes      3 times -->    379.88 Mbps in  168474.49 usec
122: 8388608 bytes      3 times -->    411.24 Mbps in  155625.68 usec
123: 8388611 bytes      3 times -->    395.81 Mbps in  161693.50 usec

And there's the end.

I would expect to see ~900 Mbps performance (in fact, a Broadcom tg3 NIC
in the same machine gives the expected ~900 Mbps performance).  The
older, 4.x e1000 series of drivers gives the ~900 Mbps performance as
expected.  I have traced the abysmal performance to the DITR code.  I
have added some output to the e1000_main.c:e1000_watchdog() section
where the Dynamic interrupt is calculated and set.  It's interesting to
note how the goc (good octet count) and the itr oscillate during the
netpipe run (ritr is the real ITR setting that is written to the e1000
ITR register):

goc(18=9+9) dif(0) ritr(1953) DITR = 2000
goc(0=0+0) dif(0) ritr(488) DITR = 8000
goc(44=22+22) dif(0) ritr(1953) DITR = 2000
goc(0=0+0) dif(0) ritr(488) DITR = 8000
goc(54=27+27) dif(0) ritr(1953) DITR = 2000

(many lines of oscillation and increased activity)

goc(0=0+0) dif(0) ritr(488) DITR = 8000
goc(10558=5299+5258) dif(41) ritr(1930) DITR = 2023
goc(0=0+0) dif(0) ritr(488) DITR = 8000
goc(9996=5228+4768) dif(459) ritr(1717) DITR = 2275
goc(0=0+0) dif(0) ritr(488) DITR = 8000
goc(11180=5378+5801) dif(422) ritr(1754) DITR = 2226
goc(0=0+0) dif(0) ritr(488) DITR = 8000
goc(10817=5304+5512) dif(208) ritr(1846) DITR = 2115


It is very interesting to note that if the 5.x driver is loaded with
InterruptThrottleRate=8000 (the default setting of the 4.x e1000 drivers
- which also disables dynamic adjustment of the ITR) then performance is
~900 Mbps:

119: 6291456 bytes      3 times -->    891.33 Mbps in   53851.83 usec
120: 6291459 bytes      3 times -->    891.34 Mbps in   53851.35 usec
121: 8388605 bytes      3 times -->    895.99 Mbps in   71429.49 usec
122: 8388608 bytes      3 times -->    881.12 Mbps in   72634.50 usec
123: 8388611 bytes      3 times -->    885.65 Mbps in   72263.48 usec

My assessment for the poor performance using is DITR is that this
reduces load on the box by limiting interrupts while increasing latency
to service the packets.  The problem is that this is done irrespective
of the actual load on the system and thus results in gratuitous latency
being added.  In other words: why limit the interrupts and reduce the
load on the system when the system isn't loaded and has nothing better
to do?  This kills performance on systems that have plenty of horsepower
to handle their load as well as service interrupts.

I recommend that the DITR formula should use the system load to scale
the 6000/2000 split, and/or that the 8000 ITR setting be the default and
the dynamic setting of ITR=1 be the option.

--- linux/drivers/net/e1000/e1000_param.c.orig	2004-05-25
18:05:10.000000000 -0700
+++ linux/drivers/net/e1000/e1000_param.c	2004-05-25 18:05:26.000000000
-0700
@@ -224,7 +224,7 @@
 #define MAX_TXABSDELAY            0xFFFF
 #define MIN_TXABSDELAY                 0
 
-#define DEFAULT_ITR                    1
+#define DEFAULT_ITR                 8000
 #define MAX_ITR                   100000
 #define MIN_ITR                      100
 


-- 
Thayne Harbaugh
Linux Networx

--=-FHfNDUzLkv+fSdAPZ3F2--
