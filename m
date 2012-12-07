From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 1/4] net: Add support for hardware-offloaded
 encapsulation
Date: Fri, 7 Dec 2012 17:13:05 +0000
Message-ID: <1354900385.2707.42.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354845419-22483-1-git-send-email-joseph.gasparakis@intel.com>
	  <1354845419-22483-2-git-send-email-joseph.gasparakis@intel.com>
	 <1354874847.20838.49.camel@deadeye.wl.decadent.org.uk>
	 <50C21D21.5040101@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	<davem@davemloft.net>, <shemminger@vyatta.com>,
	<chrisw@sous-sol.org>, <gospo@redhat.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<dmitry@broadcom.com>, <saeed.bishara@gmail.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50C21D21.5040101@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-12-07 at 08:45 -0800, Alexander Duyck wrote:
> On 12/07/2012 02:07 AM, Ben Hutchings wrote:
> > On Thu, 2012-12-06 at 17:56 -0800, Joseph Gasparakis wrote:
> >> This patch adds support in the kernel for offloading in the NIC Tx and Rx
> >> checksumming for encapsulated packets (such as VXLAN and IP GRE).
> > [...]
> >> --- a/include/linux/netdevice.h
> >> +++ b/include/linux/netdevice.h
> >> @@ -1063,6 +1063,8 @@ struct net_device {
> >>  	netdev_features_t	wanted_features;
> >>  	/* mask of features inheritable by VLAN devices */
> >>  	netdev_features_t	vlan_features;
> >> +	/* mask of features inherited by encapsulating devices */
> >> +	netdev_features_t	hw_enc_features;
> > [...]
> > 
> > How will the networking core know *which* encapsulations this applies
> > to?  I notice that your implementation in ixgbe does not set
> > NETIF_F_HW_CSUM here, so presumably the hardware will parse headers to
> > find which ranges should be checksummed and it won't cover the next
> > encapsulation protocol that comes along.
> > 
> > Ben.
> > 
> 
> Actually the offload is generic to any encapsulation that does not
> compute a checksum on the inner headers.  So as long as you can treat
> the outer headers as one giant L2 header you can pretty much ignore what
> is in there as long as the inner network and transport header values are
> set.  There are a number of tunnels that fall into that category since
> most just use IP as the L2 and the L3 usually doesn't contain any checksum.

Yes, that should work, but it requires that the driver/hardware uses the
header offsets from the skb rather than parsing the packet.  This is not
currently required for devices with the NETIF_F_IP_CSUM and
NETIF_F_IPV6_CSUM features.

Please do state explicitly which feature flags are valid in
hw_enc_features, any changes in semantics, and in particular in what
cases the driver/hardware is supposed to use header offsets from the skb
vs parsing the packet.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
