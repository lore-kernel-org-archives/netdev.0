From: Dinh Nguyen <dinguyen@opensource.altera.com>
Subject: Re: commit e34d65696d2e broke stmmac ethernet on socfpga
Date: Mon, 4 Jan 2016 09:19:02 -0600
Message-ID: <568A8D66.3080000@opensource.altera.com>
References: <56744625.8040209@opensource.altera.com> <CABgxDo+uTgYVYE-E6gQCoeWaeV=GKZVw-99JEHChDr3QAs9TkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <preid@electromag.com.au>, "David S. Miller" <davem@davemloft.net>,
	robh <robh@kernel.org>, netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	<peppe.cavallaro@st.com>
To: Romain Perier <romain.perier@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CABgxDo+uTgYVYE-E6gQCoeWaeV=GKZVw-99JEHChDr3QAs9TkA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/01/2016 02:49 AM, Romain Perier wrote:
> Hi all,
> 
> Same here on rockchip.
> See "[PATCH] stmmac: Don't exit mdio registration when mdio subnode is
> not found in the DTS"
> 
> Regards,
> Romain
> 
> 2015-12-18 18:45 GMT+01:00 Dinh Nguyen <dinguyen@opensource.altera.com>:
>> Hi,
>>
>> It appears that commit e34d65696d2e 'stmmac: create of compatible mdio
>> bus for
>> stmmac driver' is causing this error on the SoCFPGA platform:
>>
>> [    1.767246] libphy: PHY stmmac-0:ffffffff not found
>> [    1.772106] eth0: Could not attach to PHY
>> [    1.776129] stmmac_open: Cannot attach to PHY (error: -19)
>> [    1.781590] IP-Config: Failed to open eth0
>> [    1.785681] IP-Config: No network devices available
>>
>> Doing a revert of this commit fixes the issue. Will try to debug further.
>>

There error is here:

[    0.663275] socfpga-dwmac ff702000.ethernet eth0: NO MDIO subnode

It appears that his commit requires an update to DTS files, which will
subsequently break legacy DTS.

Also, this commit is only in linux-next.

Dinh
