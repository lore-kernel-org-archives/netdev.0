From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH] stmmac: CSR clock configuration fix
Date: Thu, 22 Dec 2016 10:15:20 +0000
Message-ID: <41c56a6a-b7ce-6305-5dbb-02a023df5642@synopsys.com>
References: <6d4c6d15a60c93a8aef5e3e03b9cd64cdcf232c8.1482232420.git.jpinto@synopsys.com>
 <20161221.132104.1026207180067066991.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <peppe.cavallaro@st.com>, <hock.leong.kweh@intel.com>,
        <niklas.cassel@axis.com>, <pavel@ucw.cz>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <Joao.Pinto@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161221.132104.1026207180067066991.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Às 6:21 PM de 12/21/2016, David Miller escreveu:
> From: Joao Pinto <Joao.Pinto@synopsys.com>
> Date: Tue, 20 Dec 2016 11:21:47 +0000
> 
>> When testing stmmac with my QoS reference design I checked a problem in the
>> CSR clock configuration that was impossibilitating the phy discovery, since
>> every read operation returned 0x0000ffff. This patch fixes the issue.
>>
>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> 
> This isn't enough.
> 
> It looks like various parts of this driver set the mask field
> differently.
> 
> dwmac1000_core.c and dwmac100_core.c set the mask to be the low bits.
> 
> But dwmac4_core.c uses GENMASK(11, 8) which means the mask is a value
> which is shifted up already.
> 
> So your patch will break chips driven by dwmac4_core.c.

I am using a GMAC4 reference design to test the patches. The clock configuration
as is, does not work, resulting in the phy discovery failure. By applying this
patch I am able to set the clock value properly.

I am going to check in the Databook of GMAC4 and older versions in order to
justify better.

> 
> In order for your change to be correct you must consolidate all of
> these various pieces to use the same convention.
> 

Thanks.
