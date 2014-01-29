From: Max Filippov <jcmvbkbc@gmail.com>
Subject: Re: [PATCH v2 2/4] net: ethoc: don't advertise gigabit speed on
 attached PHY
Date: Wed, 29 Jan 2014 11:01:06 +0400
Message-ID: <CAMo8BfJ_nce_H_8HJ7iw9ME=8C+sjF_Q43RaDG+1eVrpxWRvdQ@mail.gmail.com>
References: <1390975218-13863-1-git-send-email-jcmvbkbc@gmail.com>
	<1390975218-13863-3-git-send-email-jcmvbkbc@gmail.com>
	<52E8A407.1020809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Chris Zankel <chris@zankel.net>,
	Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52E8A407.1020809@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 29, 2014 at 10:47 AM, Florian Fainelli <f.fainelli@gmail.co=
m> wrote:
> Hi Max,
>
> Le 28/01/2014 22:00, Max Filippov a =C3=A9crit :
>
>> OpenCores 10/100 Mbps MAC does not support speeds above 100 Mbps, bu=
t does
>> not disable advertisement when PHY supports them. This results in
>> non-functioning network when the MAC is connected to a gigabit PHY
>> connected
>> to a gigabit switch.
>>
>> The fix is to disable gigabit speed advertisement on attached PHY
>> unconditionally.
>>
>> Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
>> ---
>> Changes v1->v2:
>> - disable both gigabit advertisement and support.
>>
>>   drivers/net/ethernet/ethoc.c | 8 ++++++++
>>   1 file changed, 8 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/eth=
oc.c
>> index 4de8cfd..5643b2d 100644
>> --- a/drivers/net/ethernet/ethoc.c
>> +++ b/drivers/net/ethernet/ethoc.c
>> @@ -688,6 +688,14 @@ static int ethoc_mdio_probe(struct net_device *=
dev)
>>         }
>>
>>         priv->phy =3D phy;
>> +       phy_update_advert(phy,
>> +                         ADVERTISED_1000baseT_Full |
>> +                         ADVERTISED_1000baseT_Half, 0);
>> +       phy_start_aneg(phy);
>
>
> This does not look necessary, you should not have to call phy_start_a=
neg()
> because the PHY state machine is not yet started, at best this calls =
does
> nothing.

This call actually makes the whole thing work, because otherwise once g=
igabit
support is cleared from the supported mask genphy_config_advert does no=
t
update gigabit advertisement register, leaving it enabled.

>> +       phy_update_supported(phy,
>> +                            SUPPORTED_1000baseT_Full |
>> +                            SUPPORTED_1000baseT_Half, 0);
>> +
>>         return 0;
>>   }
>>
>>
>

--=20
Thanks.
-- Max
