From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: [PATCH net-next v1 1/1] net: fec: Add VLAN receive HW support.
Date: Thu, 27 Jun 2013 10:35:03 +0100
Message-ID: <51CC0747.2080904@mentor.com>
References: <Jim Baxter <jim_baxter@mentor.com> <1372204524-27798-1-git-send-email-jim_baxter@mentor.com> <9848F2DB572E5649BA045B288BE08FBE014FE4E1@039-SN2MPN1-023.039d.mgd.msft.net> <51CABDD0.7050606@mentor.com> <9848F2DB572E5649BA045B288BE08FBE01501A58@039-SN2MPN1-023.039d.mgd.msft.net> <51CAD44E.6030308@mentor.com> <9848F2DB572E5649BA045B288BE08FBE01505F40@039-SN2MPN1-023.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Li Frank-B20596 <B20596@freescale.com>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Shawn Guo <shawn.guo@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Duan Fugang-B38611 <B38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:37340 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739Ab3F0JfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 05:35:12 -0400
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE01505F40@039-SN2MPN1-023.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/06/13 02:41, Duan Fugang-B38611 wrote:
> On 06/26/13 19:45, Jim Baxter wrote:
> 
>> On 26/06/13 12:18, Duan Fugang-B38611 wrote:
>>> On 06/26/13 18:09, Jim Baxter wrote:
>>>>
>>>>> In addition,
>>>>> 	1.	enet IP support hw VLAN detect such as imx28-fec, imx6q-fec and mvf600-fec, so you can add the "BD_ENET_RX_VLAN " to those platform driver_data.
>>>> I have only tested it on the i.MX6, if someone wants to check it on 
>>>> the
>>>> imx28 later they can add it to that option.
>>>
>>>>> 	2.	Enable the VLAN tag extraction with "NETIF_F_HW_VLAN_CTAG_RX" feature in .ndo_fix_features, which is configured by user.
>>>> What do you mean by this, I am only enabling the VLAN code if 
>>>> (ndev->features & NETIF_F_HW_VLAN_CTAG_RX) is set. I am pretty sure 
>>>> this is set by
>>>
>>> You can enable the feature like below, which is reasonable.
>>> .ndo_fix_features   = fec_enet_fix_features
>>>
>>> static netdev_features_t fec_enet_fix_features (struct net_device *dev, 
>>>         netdev_features_t features)
>>> {
>>>         struct fec_enet_private *fep = netdev_priv(dev);
>>> 	  const struct platform_device_id *id_entry =
>>> 					platform_get_device_id(fep->pdev);
>>>
>>> 	  if (id_entry->driver_data & FEC_QUIRK_HAS_VLAN)
>>>         	features |= NETIF_F_HW_VLAN_CTAG_RX;
>>>
>>> 	  return features;
>>> }
>>>
>>>
>>> Thank you,
>>> Andy
>>>
>>>
>>
>> I currently set the features in fec_enet_init() along with setting hw_features, is fec_enet_fix_features() a more correct design for driver implementation point?
> 
> Yes, I think it is more reasonable.
> Can you hold on the patch to hear others' idea.
> 
> Thanks,
> Andy
> 
> 

Yes, I am will wait for other comments.

Thank you,
Jim
