From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next 2/5] stmmac: allow mtu bigger than 1500 in case of
 normal desc (V2).
Date: Fri, 14 Oct 2011 09:15:09 +0200
Message-ID: <4E97E17D.4010705@st.com>
References: <1318426688-9419-1-git-send-email-peppe.cavallaro@st.com>  <1318426688-9419-3-git-send-email-peppe.cavallaro@st.com> <1318449481.2644.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Deepak SIKRI <deepak.sikri@st.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:42098 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755025Ab1JNHPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 03:15:16 -0400
In-Reply-To: <1318449481.2644.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric

On 10/12/2011 9:58 PM, Eric Dumazet wrote:
> Le mercredi 12 octobre 2011 =C3=A0 15:38 +0200, Giuseppe CAVALLARO a =
=C3=A9crit :
>> This patch allows to set the mtu bigger than 1500
>> in case of normal descriptors.
>> This is helping some SPEAr customers.
>>
>> Signed-off-by: Deepak SIKRI <deepak.sikri@st.com>
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> ---
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    6 +++---
>>  1 files changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/dri=
vers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> index ba7af2c..de3e536 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> @@ -1357,17 +1357,17 @@ static void stmmac_set_rx_mode(struct net_de=
vice *dev)
>>  static int stmmac_change_mtu(struct net_device *dev, int new_mtu)
>>  {
>>  	struct stmmac_priv *priv =3D netdev_priv(dev);
>> -	int max_mtu;
>> +	int max_mtu =3D ETH_DATA_LEN;
>=20
> Why are you setting max_mtu to ETH_DATA_LEN here ?
>=20
>> =20
>>  	if (netif_running(dev)) {
>>  		pr_err("%s: must be stopped to change its MTU\n", dev->name);
>>  		return -EBUSY;
>>  	}
>> =20
>> -	if (priv->plat->has_gmac)
>> +	if (priv->plat->enh_desc)
>>  		max_mtu =3D JUMBO_LEN;
>>  	else
>> -		max_mtu =3D ETH_DATA_LEN;
>> +		max_mtu =3D BUF_SIZE_4KiB;
>=20
> Since later you init to completely different values...


Hmm, yes you are right. it's not needed to initialized the max_mtu.

Thanks! I'll rework the patch and send it again in the V3.

Thx

Regards
Peppe

>=20
>=20
>=20
>=20
