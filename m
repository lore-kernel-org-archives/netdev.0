From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH net-next V0 19/21] mlx4_core: Modify driver
 initialization flow to accommodate SRIOV for Ethernet
Date: Tue, 6 Dec 2011 17:41:40 +0000
Message-ID: <1323193300.2772.5.camel@bwh-desktop>
References: <4ED8A636.40901@mellanox.co.il>
	 <1323120413.2887.50.camel@bwh-desktop>
	 <201112061035.54093.jackm@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
To: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201112061035.54093.jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-12-06 at 10:35 +0200, Jack Morgenstein wrote:
> On Monday 05 December 2011 23:26, Ben Hutchings wrote:
> > The 'probe_vf' parameter is very odd.  Why do you think it is necessary
> > to make this a module parameter?  It should be possible to bind and
> > unbind the driver from each VF dynamically via sysfs but this parameter
> > appears to restrict that.
> > 
> The host which sees the PF will also see all the VFs once they come up.
> As each VF appears (as seen by 'lspci'), the O/S will invoke the "probe"
> method for that VF.  Without the "probe_vf" parameter, this probe would
> result in all the VFs being bound to the PF host (and thus unavailable for
> guests).

As I said, you can unbind it through sysfs.

> The small section of code which makes use of the probe_vf parameter
> (file net/ethernet/mellanox/mlx4_main.c):

Yes, I get it.

> 	/* Detect if this device is a virtual function */
> 	if (id && id->driver_data & MLX4_VF) {
> 		/* When acting as pf, we normally skip vfs unless explicitly
> 		 * requested to probe them. */
> 		if (sr_iov && extended_func_num(pdev) > probe_vf) {
> 			mlx4_warn(dev, "Skipping virtual function:%d\n",
> 						extended_func_num(pdev));
> 			err = -ENODEV;
> 			goto err_free_dev;
> 		}
> 
> If you invoke "dmesg" on the PF host, you will see a series of the
> "Skipping... " messages, one per VF.  If probe_vf > 0, the PF-host will
> reserve some VFs for its own use, and not issue the "Skipping..." message
> for those VFs.

What if you want to change that later?  You can't use those VFs in the
PF-host without reloading the driver.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
