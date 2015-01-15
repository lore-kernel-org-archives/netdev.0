From: wstephen-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Subject: Re: [PATCH] ethernet: atheros: Add nss-gmac driver
Date: Thu, 15 Jan 2015 08:12:51 -0000
Message-ID: <bca0eaf2183036ff6a913daea6e09ad9.squirrel@www.codeaurora.org>
References: <1420754626-30121-1-git-send-email-wstephen@codeaurora.org>
    <5550127.3sXOcCISZN@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Stephen Wang" <wstephen-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, jcliburn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Arnd Bergmann" <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5550127.3sXOcCISZN@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Arnd, Francois

The nss-gmac driver is for the internal GMAC IP in the Qualcomm IPQ806x
SoC. There are 2 ARM cores and 2 NSS cores inside the IPQ806x SoC. The
main purpose of these NSS cores is to offload the networking stack from
the ARM cores to achieve high performance at routing/ipsec..etc without
exhausting the ARM core CPU cycles. There is another nss-drv driver for
the NSS cores.
The nss-gmac driver is designed to work standalone or with the nss-drv
driver so the switchable data plane overlay was implemented. When it
worked standalone, the data plane is running on the ARM core as a standard
networking driver. The nss-drv driver can take over the data plane and
offload it to the NSS cores. The STMicro stmmac driver does not have this
kind of overlay design so is not suitable for IPQ806x. This is why we
don't based on the stmmac driver

Thanks,
Stephen

>> diff --git a/drivers/net/ethernet/atheros/nss-gmac/LICENSE.txt
>> b/drivers/net/ethernet/atheros/nss-gmac/LICENSE.txt
>> new file mode 100644
>> index 0000000..806f2e6
>> --- /dev/null
>> +++ b/drivers/net/ethernet/atheros/nss-gmac/LICENSE.txt
>> @@ -0,0 +1,14 @@
>> +Linux Driver for 3504 DWC Ether MAC 10/100/1000 Universal
>> +Linux Driver for 3507 DWC Ether MAC 10/100 Universal
>> +
>> +IMPORTANT: Synopsys Ethernet MAC Linux Software Drivers and
>> documentation (hereinafter, "Software") are unsupported proprietary
>> works of Synopsys, Inc. unless otherwise expressly agreed to in writing
>> between Synopsys and you.
>> +
>> +The Software uses certain Linux kernel functionality and may therefore
>> be subject to the GNU Public License which is available at:
>> +http://www.gnu.org/licenses/gpl.html
>
> It sounds like this one is related to the dwmac driver in
> drivers/net/ethernet/stmicro/stmmac/. Please move the code into
> the same directory and reuse as much as you can.
>
> If this is a completely unrelated part, it should probably go
> into drivers/net/ethernet/designware or drivers/net/ethernet/synopsys.
>
>> +#ifdef CONFIG_OF
>> +#include <msm_nss_gmac.h>
>> +#else
>> +#include <mach/msm_nss_gmac.h>
>> +#endif
>
> Drop the non-CONFIG_OF part here and elsewhere, we don't support
> separate platform directories any more, and mach-qcom is already
> DT-only.
>
>> +/**********************************************************
>> + * GMAC registers Map
>> + * For Pci based system address is BARx + gmac_register_base
>> + * For any other system translation is done accordingly
>> + **********************************************************/
>> +enum gmac_registers {
>> +	gmac_config = 0x0000,		/* Mac config Register                */
>> +	gmac_frame_filter = 0x0004,	/* Mac frame filtering controls       */
>> +	gmac_hash_high = 0x0008,	/* Multi-cast hash table high         */
>> +	gmac_hash_low = 0x000c,		/* Multi-cast hash table low          */
>> +	gmac_gmii_addr = 0x0010,	/* GMII address Register(ext. Phy)    */
>> +	gmac_gmii_data = 0x0014,	/* GMII data Register(ext. Phy)       */
>> +	gmac_flow_control = 0x0018,	/* Flow control Register              */
>> +	gmac_vlan = 0x001c,		/* VLAN tag Register (IEEE 802.1Q)    */
>> +	gmac_version = 0x0020,		/* GMAC Core Version Register         */
>> +	gmac_wakeup_addr = 0x0028,	/* GMAC wake-up frame filter adrress
>> +					   reg				      */
>
> This looks a lot like dwmac1000 as well.
>
>> +	if (of_property_read_u32(np, "qcom,id", &gmacdev->macid)
>> +		|| of_property_read_u32(np, "qcom,emulation", &gmaccfg->emulation)
>> +		|| of_property_read_u32(np, "qcom,phy_mii_type",
>> &gmaccfg->phy_mii_type)
>> +		|| of_property_read_u32(np, "qcom,phy_mdio_addr",
>> &gmaccfg->phy_mdio_addr)
>> +		|| of_property_read_u32(np, "qcom,rgmii_delay",
>> &gmaccfg->rgmii_delay)
>> +		|| of_property_read_u32(np, "qcom,poll_required",
>> &gmaccfg->poll_required)
>> +		|| of_property_read_u32(np, "qcom,forced_speed",
>> &gmaccfg->forced_speed)
>> +		|| of_property_read_u32(np, "qcom,forced_duplex",
>> &gmaccfg->forced_duplex)
>> +		|| of_property_read_u32(np, "qcom,irq", &netdev->irq)
>> +		|| of_property_read_u32(np, "qcom,socver", &gmaccfg->socver)) {
>
> This is not an acceptable way to pass data from DT, please use the
> standard properties.
>
>> +	if (test_bit(__NSS_GMAC_LINKPOLL, &gmacdev->flags)) {
>> +#if (LINUX_VERSION_CODE <= KERNEL_VERSION(3, 8, 0))
>> +		gmacdev->phydev = phy_connect(netdev, (const char *)phy_id,
>> +					      &nss_gmac_adjust_link, 0, phyif);
>> +#else
>> +		gmacdev->phydev = phy_connect(netdev, (const char *)phy_id,
>> +					      &nss_gmac_adjust_link, phyif);
>> +#endif
>
> Drop all LINUX_VERSION_CODE checks
>
>> +		if (IS_ERR_OR_NULL(gmacdev->phydev)) {
>> +			netdev_dbg(netdev, "PHY %s attach FAIL", phy_id);
>> +			ret = -EIO;
>> +			goto nss_gmac_phy_attach_fail;
>> +		}
>
> Also any IS_ERR_OR_NULL checks, you are using the API incorrectly.
>
>> +static struct of_device_id nss_gmac_dt_ids[] = {
>> +	{ .compatible =  "qcom,nss-gmac0" },
>> +	{ .compatible =  "qcom,nss-gmac1" },
>> +	{ .compatible =  "qcom,nss-gmac2" },
>> +	{ .compatible =  "qcom,nss-gmac3" },
>> +	{},
>> +};
>> +MODULE_DEVICE_TABLE(of, nss_gmac_dt_ids);
>
> Are all four versions supported by this driver?
>
> Each one of these needs its own devicetree binding that documents which
> hardware it is for and what the supported DT properties are.
>
>> +static struct platform_driver nss_gmac_drv = {
>> +	.probe = nss_gmac_probe,
>> +	.remove = nss_gmac_remove,
>> +	.driver = {
>> +		   .name = "nss-gmac",
>> +		   .owner = THIS_MODULE,
>> +#ifdef CONFIG_OF
>> +		   .of_match_table = of_match_ptr(nss_gmac_dt_ids),
>> +#endif
>
> The redundancy here is redundant and unnecessary.
>
>> +
>> +/**
>> + * @brief IOCTL interface.
>> + * This function is mainly for debugging purpose.
>> + * This provides hooks for Register read write, Retrieve descriptor
>> status
>> + * and Retreiving Device structure information.
>> + * @param[in] pointer to net_device structure.
>> + * @param[in] pointer to ifreq structure.
>> + * @param[in] ioctl command.
>> + * @return Returns 0 on success Error code on failure.
>> + */
>> +static int32_t nss_gmac_linux_do_ioctl(struct net_device *netdev,
>> +                                      struct ifreq *ifr, int32_t cmd)
>> +{
>
> Remove the private ioctls.
>
>> +/**
>> + * @brief Stats Callback to receive statistics from NSS
>> + * @param[in] pointer to gmac context
>> + * @param[in] pointer to gmac statistics
>> + * @return Returns void.
>> + */
>> +static void nss_gmac_stats_receive(struct nss_gmac_dev *gmacdev,
>> +					struct nss_gmac_stats *gstat)
>> +{
> ...
>> +}
>> +EXPORT_SYMBOL(nss_gmac_receive);
>
> Why multiple modules instead of linking everything together?
>
>> +
>> +/**
>> + * NSS Driver interface APIs
>> + */
>
> What is an NSS driver?
>
>> +/*
>> + * nss_gmac_open_work()
>> + *	Schedule delayed work to open the netdev again
>> + */
>> +void nss_gmac_open_work(struct work_struct *work)
>> +{
>> +	struct nss_gmac_dev *gmacdev = container_of(to_delayed_work(work),
>> +						struct nss_gmac_dev, gmacwork);
>> +
>> +	netdev_dbg(gmacdev->netdev, "Do the network up in delayed queue %s\n",
>> +							gmacdev->netdev->name);
>> +	nss_gmac_linux_open(gmacdev->netdev);
>> +}
>
> You seem to have an operating system abstraction layer in here. We know
> which OS we are running on, so please remove the abstraction.
>
> 	Arnd
>


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
