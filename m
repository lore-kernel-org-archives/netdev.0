From: David Daney <ddaney.cavm@gmail.com>
Subject: Re: [PATCH v2 0/4] netdev/phy: 10G PHY support.
Date: Thu, 28 Jun 2012 10:05:52 -0700
Message-ID: <4FEC8EF0.6080408@gmail.com>
References: <1340818418-10382-1-git-send-email-ddaney.cavm@gmail.com> <20120627.212941.485325944406335522.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: grant.likely@secretlab.ca, rob.herring@calxeda.com,
	devicetree-discuss@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
	afleming@gmail.com, david.daney@cavium.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120627.212941.485325944406335522.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/27/2012 09:29 PM, David Miller wrote:
> From: David Daney<ddaney.cavm@gmail.com>
> Date: Wed, 27 Jun 2012 10:33:34 -0700
>
>> From: David Daney<david.daney@cavium.com>
>>
>> The only non-cosmetic change from v1 is to pass an additional argume=
nt
>> to get_phy_device() that indicates that the PHY uses 802.3 clause 45
>> signaling, previously I had been using a high order bit of the addr
>> parameter for this.
>>
>> There are also changes from v1 in the code and comment formatting.
>> These should now be closer to what David Miller prefers.
>
> Applied, but I had to add the following warning fixup:

Thank You.

>
> --------------------
> phy: Fix warning in get_phy_device().
>
> drivers/net/phy/phy_device.c: In function =A1get_phy_device=A2:
> drivers/net/phy/phy_device.c:340:14: warning: =A1phy_id=A2 may be use=
d uninitialized in this function [-Wmaybe-uninitialized]
>
> GCC can't see that when we return zero we always initialize
> phy_id and that's the only path where we use it.
>
> Initialize phy_id to zero to shut it up.
>

=46WIW: I was testing with GCC-4.6.3 and saw no such warnings.

David Daney


> Signed-off-by: David S. Miller<davem@davemloft.net>
> ---
>   drivers/net/phy/phy_device.c |    4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_devic=
e.c
> index ef4cdee..47e02e7 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -327,9 +327,9 @@ static int get_phy_id(struct mii_bus *bus, int ad=
dr, u32 *phy_id,
>    */
>   struct phy_device *get_phy_device(struct mii_bus *bus, int addr, bo=
ol is_c45)
>   {
> -	struct phy_device *dev =3D NULL;
> -	u32 phy_id;
>   	struct phy_c45_device_ids c45_ids =3D {0};
> +	struct phy_device *dev =3D NULL;
> +	u32 phy_id =3D 0;
>   	int r;
>
>   	r =3D get_phy_id(bus, addr,&phy_id, is_c45,&c45_ids);
