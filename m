From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V2 1/3] Documentation: devicetree: add multiple cpu port
 DSA binding
Date: Wed, 7 Jun 2017 16:10:02 -0500
Message-ID: <20170607211002.ubljfplyexjb6dyl@rob-hp-laptop>
References: <20170530104419.6052-1-john@phrozen.org>
 <69dd02a6-59f9-59df-f630-0ebd948451c4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <69dd02a6-59f9-59df-f630-0ebd948451c4-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2017 at 02:32:29PM -0700, Florian Fainelli wrote:
> On 05/30/2017 03:44 AM, John Crispin wrote:
> > Extend the DSA binding documentation, adding the new property required
> > when there is more than one CPU port attached to the switch.
> > 
> > Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> > Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Signed-off-by: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
> > ---
> >  Documentation/devicetree/bindings/net/dsa/dsa.txt | 61 ++++++++++++++++++++++-
> >  1 file changed, 60 insertions(+), 1 deletion(-)
> > 
> > diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
> > index cfe8f64eca4f..c164eb38ccc5 100644
> > --- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
> > +++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
> > @@ -55,6 +55,11 @@ A user port has the following optional property:
> >  - label			: Describes the label associated with this port, which
> >                            will become the netdev name.
> >  
> > +- cpu			: Option for non "cpu"/"dsa" ports. A phandle to a
> > +			  "cpu" port, which will be used for passing packets
> > +			  from this port to the host. If not present, the first
> > +			  "cpu" port will be used.
> 
> So this option essentially allow us to "partition" the switch between
> vectors of ports and their upstream/CPU port.

Could this be more generic? This is basically saying route all packets 
on this port to another port. Maybe there's some usecase to route to 
non-cpu ports?

> While using Device Tree is an obvious choice for making the initial
> partitioning, it seems like we are missing a configuration mechanism
> whereby we can properly assign ports to a specific upstream CPU port.

What determines how things are routed/partitioned? If it is purely user 
choice then I don't think this should be in DT.

> Let's move the actual discussion into patch 2 in order not to pollute
> the DT maintainers' inbox.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
