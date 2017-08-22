From: David Lamparter <equinox@diac24.net>
Subject: Re: [RFC net-next v2] bridge lwtunnel, VPLS & NVGRE
Date: Tue, 22 Aug 2017 14:06:10 +0200
Message-ID: <20170822120610.GC773745@eidolon>
References: <20170821171523.951260-1-equinox@diac24.net>
	<20170821170151.5b12a392@xeon-e3>
	<f96d548c-7a64-ae9a-d1ea-e9fd065f9303@cumulusnetworks.com>
	<20170822113207.GB773745@eidolon>
	<22d7d847-0914-dca9-66b8-4231e6e0b01c@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org, amine.kherbouche@6wind.com,
	David Lamparter <equinox@diac24.net>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <22d7d847-0914-dca9-66b8-4231e6e0b01c@cumulusnetworks.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 22, 2017 at 02:55:04PM +0300, Nikolay Aleksandrov wrote:
> On 22/08/17 14:32, David Lamparter wrote:
> > On Tue, Aug 22, 2017 at 02:01:40PM +0300, Nikolay Aleksandrov wrote:
> >> On 22/08/17 03:01, Stephen Hemminger wrote:
> >>> I know the bridge is an easy target to extend L2 forwarding, but it is not
> >>> the only option. Have you condidered building a new driver (like VXLAN does)
> >>> which does the forwarding you want. Having all features in one driver
> >>> makes for worse performance, and increased complexity.
> >>>
> >>
> >> +1
> >>
> >> As I said before, a separate implementation will be much cleaner and will not affect
> >> the bridge in any way, paying both performance and complexity price for something that
> >> the majority of users will not be using isn't worth it.  In addition this creates a
> >> silent dependency between the bridge and the fdb metadata dst users, it would be much
> >> more preferable to be able to run them separately.
> >> If there is any code that will need to be re-used by VPLS (or anyone else) figure out a way
> >> to factor it out.
> > 
> > Could you tell me why this argument didn't apply to the bridge vlan
> > tunnel code?  It adds complexity to the bridge specifically for VXLAN
> > (and it does *not* transfer to VPLS or 802.11) and reduces performance
> > 
> > ... by actually accessing the same metadata that this patchset does.
> 
> The separation is clean and does not add any dependencies, that code
> is well isolated.  As for performance, the impact is minimal as it
> adds a test for a port flag that is already in the cache at that
> point.

Ah, ok, now this is useful input... I can add a BR_PORT_METADATA flag.

> In fact it can be compiled-out entirely if you disable bridge vlan
> support. The metadata you're referring to is not accessed if the port
> flag is not set or vlan support is compiled out removing its impact
> entirely.

Ok, I can probably adapt this patchset to do the same.

> You can have a vxlan setup without bridge, no ?

You can run the VPLS code without a bridge too... behaviour will be the
same as with other ip tunnels when you set the destination to multicast
(packets get flooded.)


-David
