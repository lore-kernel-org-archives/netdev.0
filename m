From: boris brezillon <b.brezillon@overkiz.com>
Subject: Re: [RFC PATCH] phylib: mdio: handle register/unregister/register
 sequence
Date: Thu, 22 Aug 2013 15:14:17 +0200
Message-ID: <52160EA9.4060801@overkiz.com>
References: <1377174836-10569-1-git-send-email-b.brezillon@overkiz.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Nick Bowler <nbowler@elliptictech.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org,
 Grant Likely <grant.likely@secretlab.ca>, Mark Brown <broonie@kernel.org>,
 netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org
To: Boris BREZILLON <b.brezillon@overkiz.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1377174836-10569-1-git-send-email-b.brezillon@overkiz.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 22/08/2013 14:33, Boris BREZILLON wrote:
> Hello,
>
> This patch is a proposal to support the register/unregister/register
> sequence on a given mdio bus.

I forgot to ask, if this limitation was made on purpose ?
In other terms: no one should ever try to register, unregister and 
register again
a given mii_bus structure.

>
> I use the register/unregister/register sequence to add a fallback when the
> of_mdiobus_register (this function calls mdiobus_register with phy_mask
> set to ~0) does not register any phy device (because the device tree does
> not define any phy).
> In this case I call mdiobus_unregister and then call mdiobus_register with
> a phy_mask set to 0 to trigger a full mdio bus scan.
>
> I'm not sure this is the right way to do it (this is why I added RFC in the
> subject).
>
> Could someone help me figuring out what I should use to implement my fallback ?
>
> 1) use the register/unregister/register sequence
> 2) reimplement the "for (i = 0; i < PHY_MAX_ADDR; i++)" mdiobus_scan loop
>
> Thanks.
>
> Best Regards,
> Boris
>
> Boris BREZILLON (1):
>    phylib: mdio: handle register/unregister/register sequence
>
>   drivers/net/phy/mdio_bus.c |    6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)
>
