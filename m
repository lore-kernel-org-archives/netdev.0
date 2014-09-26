From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] net: stmmac: fix stmmac_pci_probe failed when CONFIG_HAVE_CLK
 is selected
Date: Fri, 26 Sep 2014 14:05:38 +0200
Message-ID: <54255692.8020402@st.com>
References: <1411043650-31712-1-git-send-email-hock.leong.kweh@intel.com> <20140922.141921.577008114679288180.davem@davemloft.net> <F54AEECA5E2B9541821D670476DAE19C2B7EAE19@PGSMSX102.gar.corp.intel.com> <54210EC1.9070507@st.com> <F54AEECA5E2B9541821D670476DAE19C2B7EAF23@PGSMSX102.gar.corp.intel.com> <54226020.50008@st.com> <F54AEECA5E2B9541821D670476DAE19C2B7EB35E@PGSMSX102.gar.corp.intel.com>
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
In-Reply-To: <F54AEECA5E2B9541821D670476DAE19C2B7EB35E@PGSMSX102.gar.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/24/2014 12:48 PM, Kweh, Hock Leong wrote:
>> -----Original Message-----
>> From: Giuseppe CAVALLARO [mailto:peppe.cavallaro@st.com]
>> Sent: Wednesday, September 24, 2014 2:10 PM
>>>
>>> Hi peppe,
>>>
>>> Appreciate for the explanation. Just to clarify that I am not asking not to
>> pass in the priv->stmmac_clk.
>>> In fact, the fix will fail at case 2 if driver cannot obtain the priv->stmmac_clk,
>> but just not the case 1.
>>> For case 1, seem like it does not require the stmmac_clk then I think
>>> it should be OK not to fail it when driver did not get stmmac_clk but have
>> the clk_csr set.
>>
>> ok we can do that but this clock is also managed when the iface is down.
>> Maybe it could be convenient to manage it for power consumption.
>> What do you think?
>
> Hi peppe,
>
> I don't really get what you mean here. Are you telling that you are OK with the fix?
> Or you are referring to the bottom idea which introduce clock registration APIs to
> stmmac_pci driver?

I just meant that if no clock is passed then the probe doesn't fail and
we can keep a dev_warn. Pls surround the code with a comment and repost
the patch. Let me know and sorry for the delay on replying.

peppe

>
> Regarding the power management, isn't this taking care by the PCI framework itself
> for the PCI devices / PCI cards?
>
> Sorry, may be would need you to provide a big picture to this. Thanks. :)
>
>>
>>> Anyway, I can change the fix by adding the clock registration APIs
>>> being call at the stmmac_pci.c probe there before calling
>>> stmmac_dvr_probe. By doing this, it created a dependency to the pci
>>> driver that must have CONFIG_HAVE_CLK to be turned on. Besides, I
>> would need you guys to provide me information on other platforms about
>> what is the best value to set? Can I just set to zero since the stmmac_pci
>> driver is always using the priv->plat->clk_csr?
