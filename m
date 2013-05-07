From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH v2 4/8] net: sh-eth: Remove SH_ETH_HAS_TSU and use tsu of
 sh_eth_cpu_data instead
Date: Tue, 07 May 2013 11:57:39 +0900
Message-ID: <51886DA3.5000304@renesas.com>
References: <1366279869-23387-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <1366279869-23387-4-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <517005EF.20801@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor2.renesas.com ([210.160.252.172]:40610 "EHLO
	relmlor2.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757431Ab3EGC5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 22:57:41 -0400
Received: from relmlir2.idc.renesas.com ([10.200.68.152])
 by relmlor2.idc.renesas.com ( SJSMS)
 with ESMTP id <0MME00BE0QW3G760@relmlor2.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 11:57:40 +0900 (JST)
Received: from relmlac3.idc.renesas.com ([10.200.69.23])
 by relmlir2.idc.renesas.com ( SJSMS)
 with ESMTP id <0MME00E15QW3DEG0@relmlir2.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 11:57:39 +0900 (JST)
In-reply-to: <517005EF.20801@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

(2013/04/18 23:40), Sergei Shtylyov wrote:
> On 18-04-2013 14:11, Nobuhiro Iwamatsu wrote:
>
>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>> ---
> [...]
>
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
>> index 5c4e82c..7de0b0e 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> [...]
>> @@ -2597,16 +2591,11 @@ static const u16 *sh_eth_get_register_offset(int register_type)
>> return reg_offset;
>> }
>>
>> -static const struct net_device_ops sh_eth_netdev_ops = {
>> +static struct net_device_ops sh_eth_netdev_ops = {
>> .ndo_open = sh_eth_open,
>> .ndo_stop = sh_eth_close,
>> .ndo_start_xmit = sh_eth_start_xmit,
>> .ndo_get_stats = sh_eth_get_stats,
>> -#if defined(SH_ETH_HAS_TSU)
>> - .ndo_set_rx_mode = sh_eth_set_multicast_list,
>> - .ndo_vlan_rx_add_vid = sh_eth_vlan_rx_add_vid,
>> - .ndo_vlan_rx_kill_vid = sh_eth_vlan_rx_kill_vid,
>> -#endif
>> .ndo_tx_timeout = sh_eth_tx_timeout,
>> .ndo_do_ioctl = sh_eth_do_ioctl,
>> .ndo_validate_addr = eth_validate_addr,
>> @@ -2687,6 +2676,15 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
>> sh_eth_set_default_cpu_data(mdp->cd);
>>
>> /* set function */
>> + if (mdp->cd->tsu) {
>> + sh_eth_netdev_ops.ndo_set_rx_mode
>> + = sh_eth_set_multicast_list;
>> + sh_eth_netdev_ops.ndo_vlan_rx_add_vid
>> + = sh_eth_vlan_rx_add_vid;
>> + sh_eth_netdev_ops.ndo_vlan_rx_kill_vid
>> + = sh_eth_vlan_rx_kill_vid;
>> + }
>> +
>
> What if there's multiple Ether devices, only one of which has TSU? Or that never happens?
>

Now, the device with TSU has TSU matually.
I think that it is no problem now.
Althought it is also considered that only one of the two will have
TSU in the future, I don't think that it is necessary to correspond
now since there is no device.

Of cource, I think that the coreesponding good.

Best regards,
   Nobuhiro
