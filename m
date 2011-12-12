From: Veli-Pekka Peltola <veli-pekka.peltola@bluegiga.com>
Subject: Re: [PATCH 1/1] net/fec: add KSZ9021RN phy fixup
Date: Mon, 12 Dec 2011 16:42:07 +0200
Message-ID: <4EE612BF.9050907@bluegiga.com>
References: <1323684558-16796-1-git-send-email-richard.zhao@linaro.org>
 <CAOMZO5DNRrt7ULuBkh9y8bz2_fpCHOcSWxAbJOqTHA2Nrv1V_w@mail.gmail.com>
 <20111212135119.GE16835@b20223-02.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: patches@linaro.org, netdev@vger.kernel.org, jgq516@gmail.com,
 eric.miao@linaro.org, Richard Zhao <richard.zhao@linaro.org>,
 shawn.guo@linaro.org, Fabio Estevam <festevam@gmail.com>, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: Richard Zhao <richard.zhao@freescale.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20111212135119.GE16835@b20223-02.ap.freescale.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 12/12/2011 03:51 PM, Richard Zhao wrote:
> On Mon, Dec 12, 2011 at 10:56:48AM -0200, Fabio Estevam wrote:
>> On Mon, Dec 12, 2011 at 8:09 AM, Richard Zhao<richard.zhao@linaro.org>  wrote:
>>> For imx6q sabrelite board, set phy RGMII pad skew.
>>>
>>> Signed-off-by: Richard Zhao<richard.zhao@linaro.org>
>>> ---
>>>   drivers/net/ethernet/freescale/fec.c |   19 +++++++++++++++++++
>>>   1 files changed, 19 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
>>> index 112af9b..d3b4463 100644
>>> --- a/drivers/net/ethernet/freescale/fec.c
>>> +++ b/drivers/net/ethernet/freescale/fec.c
>>> @@ -1513,6 +1513,21 @@ static inline void fec_reset_phy(struct platform_device *pdev)
>>>   }
>>>   #endif /* CONFIG_OF */
>>>
>>> +/* For imx6q sabrelite board: set KSZ9021RN RGMII pad skew */
>>> +static int ksz9021rn_phy_fixup(struct phy_device *phydev)
>>> +{
>>> +       /* min rx data delay */
>>> +       phy_write(phydev, 0x0b, 0x8105);
>>> +       phy_write(phydev, 0x0c, 0x0000);
>>> +
>>> +       /* max rx/tx clock delay, min rx/tx control delay */
>>> +       phy_write(phydev, 0x0b, 0x8104);
>>> +       phy_write(phydev, 0x0c, 0xf0f0);
>>> +       phy_write(phydev, 0x0b, 0x104);
>>> +
>>> +       return 0;
>>
>> This should go to drivers/net/phy/micrel.c.
> Why? It's specific to fec.

For me it seems to be a board specific and should be placed to the 
machine file. Please include linux/micrel_phy.h and use proper defines 
(PHY_ID_KSZ9021, MICREL_PHY_ID_MASK).

--
Veli-Pekka Peltola
