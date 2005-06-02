From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 2 Jun 2005 14:31:26 -0700
Message-ID: <20050602143126.7c302cfd@dxpl.pdx.osdl.net>
References: <468F3FDA28AA87429AD807992E22D07E0450BFD0@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <hadi@cyberus.ca>, "Jon Mason" <jdmason@us.ibm.com>,
        "David S. Miller"
 <davem@davemloft.net>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>, <netdev@oss.sgi.com>,
        <Robert.Olsson@data.slu.se>,
        "Venkatesan, Ganesh"
 <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse"
 <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Ronciak, John" <john.ronciak@intel.com>
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E0450BFD0@orsmsx408>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2 Jun 2005 14:19:55 -0700
"Ronciak, John" <john.ronciak@intel.com> wrote:

> The DRR algorithm assumes a perfect world, where hardware resources are
> infinite, packets arrive continuously (or separated by very long
> delays), there are no bus latencies, and CPU speed is infinite.
> 
> The real world is much messier: hardware starves for resources if it's
> not serviced quickly enough, packets arrive at inconvenient intervals
> (especially at 10 and 100 Mbps speeds), and buses and CPUs are slow.
> 
> Thus, the driver should have the intelligence built into it to make an
> "intelligent" choice on what the weight should be for that
> driver/hardware.  The calculation in the driver should take into account
> all the factors that the driver has access to.  These include link
> speed, bus type and speed, processor speed and some amount of actual
> device FIFO size and latency smarts.  The driver would use all of the
> factors to come up with a weight to prevent it from dropping frames and
> not to starve out other devices in the system or hinder performance.  It
> seems to us that the driver is the one that know best and should try to
> come up with a reasonable value for weight based on its own knowledge of
> the hardware.

This is like saying each CPU vendor should write their own process scheduler
for Linux. Now with NUMA and HT, it is getting almost that bad but we still
try and keep it CPU neutral.

For networking the problem is worse, the "right" choice depends on workload
and relationship between components in the system. I can't see how you could
ever expect a driver specific solution.   

> This has been showing up in our NAPI test data which Mitch is currently
> scrubbing for release.  It shows that there is a need for either better
> default static weight numbers or for them to be calculated based on some
> system dynamic variables.  We would like to see the latter tried but the
> only problem is that each driver would have to make its own
> calculations, and it may not have access to all of the system-wide data
> it would need to make a proper calculation.

And for other workloads, and other systems (think about the Altix with
long access latencies), your numbers will be wrong. Perhaps we need
to quit trying for a perfect solution and just get a "good enough" one
that works.

Let's keep the intelligence out of the driver. Most of the existing
smart drivers end up looking like crap and don't work that well.


> Even with a more intelligent driver, we still would like to see some
> mechanism for the weight to be changed at runtime, such as with
> Stephen's sysfs patch.  This would allow a sysadmin (or user-space app)
> to tune the system based on statistical data that isn't available to the
> individual driver.
> 

It will be yet another knob that all except the benchmark tweakers can
ignore (hopefully).
