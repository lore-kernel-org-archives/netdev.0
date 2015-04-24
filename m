From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: netcp: remove call to netif_carrier_(on/off) for
 MAC to Phy interface
Date: Fri, 24 Apr 2015 19:41:30 +0300
Message-ID: <553A723A.8090700@cogentembedded.com>
References: <1429816627-24337-1-git-send-email-m-karicheri2@ti.com> <553A4623.2070802@cogentembedded.com> <553A5EA8.4010908@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <553A5EA8.4010908@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/24/2015 06:18 PM, Murali Karicheri wrote:

>>> Currently when interface type is MAC to Phy, netif_carrier_(on/off)
>>> is called which is not needed as Phy lib already updates the carrier
>>> status to net stack. This is needed only for other interface types

>>> Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
>>> ---
>>>   drivers/net/ethernet/ti/netcp_ethss.c |    8 ++++++--
>>>   1 file changed, 6 insertions(+), 2 deletions(-)

>>> diff --git a/drivers/net/ethernet/ti/netcp_ethss.c
>>> b/drivers/net/ethernet/ti/netcp_ethss.c
>>> index 2bef655..0a1ef2e 100644
>>> --- a/drivers/net/ethernet/ti/netcp_ethss.c
>>> +++ b/drivers/net/ethernet/ti/netcp_ethss.c
>>> @@ -1765,7 +1765,9 @@ static void netcp_ethss_link_state_action(struct
>>> gbe_priv *gbe_dev,
>>>                        ALE_PORT_STATE,
>>>                        ALE_PORT_STATE_FORWARD);
>>>
>>> -        if (ndev && slave->open)
>>> +        if (ndev && slave->open &&
>>> +            ((slave->link_interface != SGMII_LINK_MAC_PHY) &&
>>> +            (slave->link_interface != XGMII_LINK_MAC_PHY)))

>>    You don't need extra parens around &&.

> You are right! I will fix it up and re-send.

    In fact, you don't need parens around != either.

> Mruali

[...]

WBR, Sergei
