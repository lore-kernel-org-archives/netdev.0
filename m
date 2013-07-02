From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: Re: [PATCH RFC 2/3] dt:net:stmmac: Add support to dwmac version 3.610
 and 3.710
Date: Tue, 02 Jul 2013 07:42:32 +0100
Message-ID: <51D27658.1060806@st.com>
References: <1372678962-12959-1-git-send-email-srinivas.kandagatla@st.com> <1372679034-13139-1-git-send-email-srinivas.kandagatla@st.com> <51D1BA52.3030201@st.com>
Reply-To: srinivas.kandagatla@st.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <51D1BA52.3030201@st.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Peppe for the comments,
On 01/07/13 18:20, Giuseppe CAVALLARO wrote:
> On 7/1/2013 1:43 PM, Srinivas KANDAGATLA wrote:
>> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
>>
>> +
>> +    plat->bus_id = of_alias_get_id(np, "ethernet");
>> +    if (plat->bus_id < 0)
>> +        plat->bus_id = 0;
>> +
>> +    of_property_read_u32(np, "snps,phy-addr", &plat->phy_addr);
>> +
>>       plat->mdio_bus_data = devm_kzalloc(&pdev->dev,
>>                          sizeof(struct stmmac_mdio_bus_data),
>>                          GFP_KERNEL);
>> @@ -51,11 +60,25 @@ static int stmmac_probe_config_dt(struct
>> platform_device *pdev,
>>        */
>>       if (of_device_is_compatible(np, "st,spear600-gmac") ||
>>           of_device_is_compatible(np, "snps,dwmac-3.70a") ||
>> +        of_device_is_compatible(np, "snps,dwmac-3.610") ||
I forgot to add "snps,dwmac-3.710" to this list, I will do it in V2 patch.

>>           of_device_is_compatible(np, "snps,dwmac")) {
>>           plat->has_gmac = 1;
>>           plat->pmt = 1;
>>       }
>>
>> +    if (of_device_is_compatible(np, "snps,dwmac-3.610") ||
>> +        of_device_is_compatible(np, "snps,dwmac-3.710")) {
>> +        plat->enh_desc = 1;
>> +        plat->bugged_jumbo = 1;
>> +        plat->force_sf_dma_mode = 1;
>> +    }
> 
> I think some these shouldn't be forced here. Maybe plat->enh_desc could
> be set because for new syn mac cores.
> 
> Also pmt could not be forced because it is an extra module so it could
> happen that a new chip has no PMT block.
I agree with you, But the new chips should/will have different version
numbers, so having the version number in the compatible string should
make it possible for cores without PMT module to not set pmt or any
other properties.

Are you happy with the setting pmt based on compatible string or do you
think passing pmt as another property to device tree makes more sense?

Thanks,
srini

