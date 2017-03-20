From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: [PATCH net-next] stmmac: call stmmac_init_phy from
 stmmac_dvr_probe
Date: Mon, 20 Mar 2017 18:44:42 +0100
Message-ID: <5921fa33-5509-a158-80d6-acda7e68b418@axis.com>
References: <20170320172915.8313-1-niklass@axis.com>
 <ca027cda-2a8f-55d9-42e9-7f26e832e7bf@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:38574 "EHLO
        bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753580AbdCTRqL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 13:46:11 -0400
In-Reply-To: <ca027cda-2a8f-55d9-42e9-7f26e832e7bf@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/2017 06:42 PM, Joao Pinto wrote:
> Às 5:29 PM de 3/20/2017, Niklas Cassel escreveu:
>> From: Niklas Cassel <niklas.cassel@axis.com>
>>
>> It is usually possible to do
>> ethtool -s autoneg on
>> so that you trigger an autoneg before calling
>> ip link set dev eth0 up
>>
>> However, stmmac returns -EBUSY if !netif_running.
>> The only reason for this appears to be that stmmac_init_phy
>> is called from stmmac_open instead of from stmmac_dvr_probe.
>>
>> Move stmmac_init_phy to stmmac_dvr_probe so that ethool
>> works as soon as register_netdev has been called.
>> stmmac_check_ether_addr was also moved to probe,
>> so that the ordering doesn't change.
>>
>> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
>> ---
> Hi Niklas, did you test this patch?

I tested it on our hardware, but it would be nice
if you could test it on your side, since you are
using the PCI glue layer.
