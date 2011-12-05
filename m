From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH net-next V0 19/21] mlx4_core: Modify driver
 initialization flow to accommodate SRIOV for Ethernet
Date: Mon, 5 Dec 2011 21:26:53 +0000
Message-ID: <1323120413.2887.50.camel@bwh-desktop>
References: <4ED8A636.40901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	<liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>, <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
To: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4ED8A636.40901-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-12-02 at 12:19 +0200, Yevgeny Petrilin wrote:
> From: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
> 
> 1. Added module parameters sr_iov and probe_vf for controlling enablement of
>    SRIOV mode.

This sort of option is useful in many drivers, and ideally would be
specified in some generic way rather than a module parameters.  However
I can't see a good way to make it configurable after the net device is
registered.

Currently the in-tree drivers have:

be2net: num_vfs
cxgb4:  num_vfs [array]
igb:    max_vfs
ixgbe:  max_vfs

Consider renaming 'sr_iov' to one of the above rather than adding to the
variation.

The 'probe_vf' parameter is very odd.  Why do you think it is necessary
to make this a module parameter?  It should be possible to bind and
unbind the driver from each VF dynamically via sysfs but this parameter
appears to restrict that.

[...]
> 3. Added port_type_array as a module parameter to allow driver startup with
>    ports configured as desired.
>    In SRIOV mode, only ETH is supported, and this array is ignored; otherwise,
>    for the case where the FW supports both port types (ETH and IB), the
>    port_type_array parameter is used.
>    By default, the port_type_array is set to configure both ports as IB.
[...]

You seem to be saying that this can be reconfigured after startup - in
which case is the module parameter really necessary?  Maybe I
misunderstand.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
