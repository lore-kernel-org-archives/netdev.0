From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] net: stmmac: fix stmmac_pci_probe failed when CONFIG_HAVE_CLK
 is selected
Date: Wed, 24 Sep 2014 08:09:36 +0200
Message-ID: <54226020.50008@st.com>
References: <1411043650-31712-1-git-send-email-hock.leong.kweh@intel.com> <20140922.141921.577008114679288180.davem@davemloft.net> <F54AEECA5E2B9541821D670476DAE19C2B7EAE19@PGSMSX102.gar.corp.intel.com> <54210EC1.9070507@st.com> <F54AEECA5E2B9541821D670476DAE19C2B7EAF23@PGSMSX102.gar.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "rayagond@vayavyalabs.com" <rayagond@vayavyalabs.com>,
	"vbridgers2013@gmail.com" <vbridgers2013@gmail.com>,
	"wens@csie.org" <wens@csie.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ong, Boon Leong" <boon.leong.ong@intel.com>,
	"tobias.johannes.klausmann@mni.thm.de"
	<tobias.johannes.klausmann@mni.thm.de>
To: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F54AEECA5E2B9541821D670476DAE19C2B7EAF23@PGSMSX102.gar.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/23/2014 9:03 AM, Kweh, Hock Leong wrote:
>> -----Original Message-----
>> From: Giuseppe CAVALLARO [mailto:peppe.cavallaro@st.com]
>> Sent: Tuesday, September 23, 2014 2:10 PM
>>
>> the logic is: the priv->stmmac_clk must be always provided from the platform
>> then we have two cases:
>>
>> 1) if priv->plat->clk_csr is also passed then it will be adopt in the
>>      mdio functions to program the Reg4[5:2]
>>      This was required in the past IIRC on SPEAr platforms.
>>
>> 2) if priv->plat->clk_csr is not passed from the platform then the
>>      priv->clk_csr will be set according to the priv->stmmac_clk
>>      and always used in the mdio part.
>>
>> So IIUC now you are asking for not passing the priv->stmmac_clk and warning
>> this event w/o failing. Why you cannot pass this clock?
>>
>> peppe
>
>
> Hi peppe,
>
> Appreciate for the explanation. Just to clarify that I am not asking not to pass in the priv->stmmac_clk.
> In fact, the fix will fail at case 2 if driver cannot obtain the priv->stmmac_clk, but just not the case 1.
> For case 1, seem like it does not require the stmmac_clk then I think it should be OK not to fail it when
> driver did not get stmmac_clk but have the clk_csr set.

ok we can do that but this clock is also managed when the iface is down.
Maybe it could be convenient to manage it for power consumption.
What do you think?

> Anyway, I can change the fix by adding the clock registration APIs being call at the stmmac_pci.c probe there before
> calling stmmac_dvr_probe. By doing this, it created a dependency to the pci driver that must have CONFIG_HAVE_CLK
> to be turned on. Besides, I would need you guys to provide me information on other platforms about what is the best
> value to set? Can I just set to zero since the stmmac_pci driver is always using the priv->plat->clk_csr?
>
>
> Regards,
> Wilson
>
>
>
