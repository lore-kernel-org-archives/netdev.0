From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH v1 1/6] net: mv643xx_eth: properly start/stop phy device
Date: Wed, 11 Dec 2013 08:06:36 +0100
Message-ID: <52A80EFC.8070806@gmail.com>
References: <1386513631-11284-1-git-send-email-sebastian.hesselbarth@gmail.com> <1386513631-11284-2-git-send-email-sebastian.hesselbarth@gmail.com> <20131210.215253.2121948728095674632.davem@davemloft.net> <20131210.215654.1165181423931409066.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: f.fainelli@gmail.com, mugunthanvnm@ti.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131210.215654.1165181423931409066.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/11/2013 03:56 AM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 10 Dec 2013 21:52:53 -0500 (EST)
>
>>
>> This series looks good, applied to net-next, thanks.
>
> Actually, I had to revert.
>
> You cannot use late_initcall_sync() from code that is potentially
> built modular, this caused my build to fail at the mdio_bus code.
>
> drivers/net/phy/mdio_bus.c:344:1: warning: data definition has no typ=
e or storage class [enabled by default]
> drivers/net/phy/mdio_bus.c:344:1: error: type defaults to =A1int=A2 i=
n declaration of =A1late_initcall_sync=A2 [-Werror=3Dimplicit-int]
> drivers/net/phy/mdio_bus.c:344:1: warning: parameter names (without t=
ypes) in function declaration [enabled by default]
> drivers/net/phy/mdio_bus.c:339:12: warning: =A1mdio_bus_class_suspend=
_unused=A2 defined but not used [-Wunused-function]
>

Hmm, I see. What about you drop patch 5 ("net: phy: suspend unused PHYs
on mdio_bus in late_initcall"), take the rest, and I'll have look at
suspending unused PHYs later?

Sebastian
