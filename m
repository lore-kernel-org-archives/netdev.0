From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Tue, 31 May 2005 17:07:54 -0500
Message-ID: <200505311707.54487.jdmason@us.ibm.com>
References: <Pine.CYG.4.58.0505261406210.2364@mawilli1-desk2.amr.corp.intel.com> <1117241786.6251.7.camel@localhost.localdomain> <Pine.CYG.4.58.0505311029510.2128@mawilli1-desk2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        "Ronciak, John" <john.ronciak@intel.com>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitch Williams <mitch.a.williams@intel.com>
In-Reply-To: <Pine.CYG.4.58.0505311029510.2128@mawilli1-desk2.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 31 May 2005 12:35 pm, Mitch Williams wrote:
> On Fri, 27 May 2005, jamal wrote:
> > On Fri, 2005-27-05 at 14:01 -0700, Stephen Hemminger wrote:
> > > Why not just allow adjusting dev->weight via sysfs?
> >
> > I think that should be good enough - and i thought your patch already
> > did this.
> > Adding a shift to the weight in a _weighted_ RR algorithm does sound
> > odd.
>
> Stephen's patch only affects the weight for the backlog device.  Exporting
> dev-> weight to sysfs will allow the weight to be set for any network
> device.  Which makes perfect sense.
>
> I'll work on getting this done and verifying performance this week.
> Expect a patch in a few days.
>
> Thanks, guys.
>
> -Mitch

It seems to me that the drivers should adjust dev->weight dependent on the 
media speed/duplexity of the current link.  A 10Mbps link will be constantly 
re-enabling interrupts, as the incoming traffic is too slow.  Why not have it 
be 1/4 the weight of the gigabit NAPI weight, and set it when the link speed 
is detected (or forced)?  

Of course some performace analysis would have to be done to determine the 
optimal numbers for each speed/duplexity setting per driver.

Thanks,
Jon
