From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next-2.6 PATCH 0/6 v4] macvlan: MAC Address filtering
 support for passthru mode
Date: Thu, 2 Feb 2012 09:24:49 +0200
Message-ID: <20120202072448.GA25403@redhat.com>
References: <1321575301.2749.51.camel@bwh-desktop>
 <CAEE6B20.3A9F7%roprabhu@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net, chrisw@redhat.com, sri@us.ibm.com,
	dragos.tatulea@gmail.com, kvm@vger.kernel.org, arnd@arndb.de,
	gregory.v.rose@intel.com, mchan@broadcom.com, dwang2@cisco.com,
	shemminger@vyatta.com, eric.dumazet@gmail.com, kaber@trash.net,
	benve@cisco.com
To: Roopa Prabhu <roprabhu@cisco.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAEE6B20.3A9F7%roprabhu@cisco.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 20, 2011 at 08:30:24AM -0800, Roopa Prabhu wrote:
> 
> 
> 
> On 11/17/11 4:15 PM, "Ben Hutchings" <bhutchings@solarflare.com> wrote:
> 
> > Sorry to come to this rather late.
> > 
> > On Tue, 2011-11-08 at 23:55 -0800, Roopa Prabhu wrote:
> > [...]
> >> v2 -> v3
> >> - Moved set and get filter ops from rtnl_link_ops to netdev_ops
> >> - Support for SRIOV VFs.
> >>         [Note: The get filters msg (in the way current get rtnetlink handles
> >>         it) might get too big for SRIOV vfs. This patch follows existing
> >> sriov 
> >>         vf get code and tries to accomodate filters for all VF's in a PF.
> >>         And for the SRIOV case I have only tested the fact that the VF
> >>         arguments are getting delivered to rtnetlink correctly. The code
> >>         follows existing sriov vf handling code so rest of it should work
> >> fine]
> > [...]
> > 
> > This is already broken for large numbers of VFs, and increasing the
> > amount of information per VF is going to make the situation worse.  I am
> > no netlink expert but I think that the current approach of bundling all
> > information about an interface in a single message may not be
> > sustainable.
> 
> Yes agreed. I have the same concern.

So it seems that we need to extend the existing interface to allow
tweaking filters per VF. Does it need to block this
patchset though? After all, we'll need to support the existing
interface indefinitely, too.

-- 
MST
