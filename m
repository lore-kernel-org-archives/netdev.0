From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/2] introduce devm_mdiobus_alloc/devm_mdiobus_free
Date: Thu, 10 Apr 2014 21:55:29 -0700
Message-ID: <CAGVrzcZ8vXBn4omyR7+ejihhcrspt-Rz_BBh55esxNFO06gHgQ@mail.gmail.com>
References: <1396618825-4241-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Jonathan Cameron <jic23@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Prabhakar Lad <prabhakar.csengg@gmail.com>,
	santosh.shilimkar@ti.com, Sekhar Nori <nsekhar@ti.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	dlos <davinci-linux-open-source@linux.davincidsp.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1396618825-4241-1-git-send-email-grygorii.strashko@ti.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Grygorii,

2014-04-04 6:40 GMT-07:00 Grygorii Strashko <grygorii.strashko@ti.com>:
> Introduce a resource managed devm_mdiobus_alloc()/devm_mdiobus_free()
> to automatically clean up MDIO bus alocations made by MDIO drivers,
> thus leading to simplified MDIO drivers code.
>
> Update Davinci MDIO driver ss example of new devm APIs usage.

This does look good at first glance. net-next is currently closed at
the moment, so this will have to be merged later.

At some point, we might also want to handle the mdio_bus irq array, as
that one is also usually dynamically allocated. Maybe we could just do
a static irq[PHY_MAX_ADDR] allocation, 32 times the size of an integer
might not be worth a potential leak.

>
> Grygorii Strashko (2):
>   mdio_bus: implement devm_mdiobus_alloc/devm_mdiobus_free
>   net: davinci_mdio: use devm_* api
>
>  Documentation/driver-model/devres.txt  |    4 ++
>  drivers/net/ethernet/ti/davinci_mdio.c |   21 ++--------
>  drivers/net/phy/mdio_bus.c             |   68 ++++++++++++++++++++++++++++++++
>  include/linux/phy.h                    |    2 +
>  4 files changed, 78 insertions(+), 17 deletions(-)
>
> --
> 1.7.9.5
>



-- 
Florian
