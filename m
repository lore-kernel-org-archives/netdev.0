From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] drivers: net: xgene: Check all RGMII phy mode
 variants
Date: Wed, 17 May 2017 14:33:40 -0700
Message-ID: <213c3447-6df7-ceb0-ed74-3e71342b7bf5@gmail.com>
References: <1495051550-28961-1-git-send-email-isubramanian@apm.com>
 <20170517202633.GA14413@lunn.ch>
 <CAKh23FkpYd0vC-AjqQu9ZStsRNp=kFh90eRfTU5WCC6Ln7E2AA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, patches <patches@apm.com>,
 David Miller <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 Quan Nguyen <qnguyen@apm.com>
To: Iyappan Subramanian <isubramanian@apm.com>, Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAKh23FkpYd0vC-AjqQu9ZStsRNp=kFh90eRfTU5WCC6Ln7E2AA@mail.gmail.com>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 05/17/2017 02:29 PM, Iyappan Subramanian wrote:
> On Wed, May 17, 2017 at 1:26 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>>> +bool is_xgene_enet_phy_mode_rgmii(struct net_device *ndev)
>>> +{
>>> +     struct xgene_enet_pdata *pdata = netdev_priv(ndev);
>>> +     int phy_mode = pdata->phy_mode;
>>> +     bool ret;
>>> +
>>> +     ret = phy_mode == PHY_INTERFACE_MODE_RGMII ||
>>> +           phy_mode == PHY_INTERFACE_MODE_RGMII_ID ||
>>> +           phy_mode == PHY_INTERFACE_MODE_RGMII_RXID ||
>>> +           phy_mode == PHY_INTERFACE_MODE_RGMII_TXID;
>>> +
>>> +     return ret;
>>> +}
>>
>> include/linux/phy.h:
>>
>> /**
>>  * phy_interface_is_rgmii - Convenience function for testing if a PHY interface
>>  * is RGMII (all variants)
>>  * @phydev: the phy_device struct
>>  */
>> static inline bool phy_interface_is_rgmii(struct phy_device *phydev)
>> {
>>         return phydev->interface >= PHY_INTERFACE_MODE_RGMII &&
>>                 phydev->interface <= PHY_INTERFACE_MODE_RGMII_TXID;
>> };
> 
> Thanks.  I'll use this helper function.

If you can use it, that's great, the reason why I did not recommend
using it before was because it takes a phydev reference and your code
clearly could have run before connecting to the PHY device.

Alternatively, we could introduce a helper function that just checks a
phy_interface_t type, something like:

static inline bool phy_interface_is_rgmii(phy_interface_t mode)
{
	...
}

and introduce:

static inline bool phydev_interface_is_rgmii(struct phy_device *phydev)
{
	return phy_interface_is_rgmii(phydev->interface);
}

which would use this helper function internally. Or just drop the second
helper, and always pass phydev->interface where needed.
-- 
Florian
