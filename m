From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: phy: Deal with unbound PHY driver in
 phy_attached_print()
Date: Tue, 22 Aug 2017 14:45:44 -0700
Message-ID: <24d4774e-1b1b-fe8b-5d25-dcd7f7aae757@gmail.com>
References: <20170822212647.11520-1-f.fainelli@gmail.com>
 <20170822.144414.545771080170074088.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romain.perier@collabora.com,
        alexandre.torgue@st.com, peppe.cavallaro@st.com, plaes@plaes.org,
        andrew@lunn.ch, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170822.144414.545771080170074088.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/22/2017 02:44 PM, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Tue, 22 Aug 2017 14:26:47 -0700
> 
>> Priit reported that stmmac was crashing with the trace below. This is because
>> phy_attached_print() is called too early right after the PHY device has been
>> found, but before it has a driver attached, since that is only done in
>> phy_probe() which occurs later.
>>
>> Fix this by dealing with a possibly NULL phydev->drv point since that can
>> happen here, but could also happen if we voluntarily did an unbind of the
>> PHY device with the PHY driver.
>  ...
>> Tested-By: Priit Laes <plaes@plaes.org>
>> Fixes: fbca164776e4 ("net: stmmac: Use the right logging function in stmmac_mdio_register")
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> "net-next"?  The commit which introduced this problem is in 'net', don't we want
> to fix it there?

Oh yes we do, somehow I thought the commit was just in "net-next" hence
the subject, the patch applies cleanly to "net" as well.

Thanks!
-- 
Florian
