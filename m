From: Shrikrishna Khare <skhare@vmware.com>
Subject: Re: [PATCH net-next 5/7] Driver: Vmxnet3: Add support for get_coalesce,
 set_coalesce ethtool operations
Date: Sun, 8 May 2016 13:55:44 -0700 (PDT)
Message-ID: <alpine.DEB.2.10.1605081335140.13942@shri-linux.eng.vmware.com>
References: <1462576336-83513-1-git-send-email-skhare@vmware.com>  <1462576336-83513-6-git-send-email-skhare@vmware.com> <1462622686.19332.33.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="554307656-2136172662-1462740944=:13942"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com, Keyong Sun <sunk@vmware.com>,
	Manoj Tammali <tammalim@vmware.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462622686.19332.33.camel@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--554307656-2136172662-1462740944=:13942
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT



On Sat, 7 May 2016, Ben Hutchings wrote:

> On Fri, 2016-05-06 at 16:12 -0700, Shrikrishna Khare wrote:
> [...]
> > +static int
> > +vmxnet3_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *ec)
> > +{
> [...]
> > +	switch (ec->rx_coalesce_usecs) {
> > +	case VMXNET3_COALESCE_DEFAULT:
> > +	case VMXNET3_COALESCE_DISABLED:
> > +	case VMXNET3_COALESCE_ADAPT:
> > +		if (ec->tx_max_coalesced_frames ||
> > +		    ec->tx_max_coalesced_frames_irq ||
> > +		    ec->rx_max_coalesced_frames_irq) {
> > +			return -EINVAL;
> > +		}
> > +		memset(adapter->coal_conf, 0, sizeof(*adapter->coal_conf));
> > +		adapter->coal_conf->coalMode = ec->rx_coalesce_usecs;
> > +		break;
> > +	case VMXNET3_COALESCE_STATIC:
> [...]
> 
> I don't want to see drivers introducing magic values for fields that
> are denominated in microseconds (especially not for 0, which is the
> correct way to specify 'no coalescing').  If the current
> ethtool_coalesce structure is inadequate, propose an extension.

For vmxnet3, we need an ethtool mechanism to indicate coalescing mode to 
the device.

Would a patch that maps 0 to 'no coalescing' be acceptable? That is:

rx-usecs = 0 -> coalescing disabled.
rx-usecs = 1 -> default (chosen by the device).
rx-usecs = 2 -> adaptive coalescing.
rx-usecs = 3 -> static coalescing.
all other rx-usecs values -> rate based coalescing where rx-usecs denotes 
rate.

Alternatively: I don't think new members could be added to struct 
ethtool_coalesce without breaking compatibility. Thus, I could extend 
coalescing as follows:
- new struct ethtool_coalesce_v2 with coalesce_mode (along with all the 
members of struct ethtool_coalesce).
- introduce new ETHTOOL_{G,S}COALESCE_V2 commands.
- extend userspace ethtool to invoke new commands.

Could you please advice?

Thanks,
Shri
--554307656-2136172662-1462740944=:13942--
