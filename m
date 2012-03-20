From: Mohammed Shafi <shafi.wireless@gmail.com>
Subject: Re: ath: DMA failed to stop in 10 ms AR_CR=0x00000024
 AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
Date: Tue, 20 Mar 2012 17:06:23 +0530
Message-ID: <CAD2nsn1SxhX3MZTF+XYN=cQEfHuD9bu5_TuLtVOCNmVBoZNJ2A@mail.gmail.com>
References: <4F576FD5.2050208@gmail.com>
	<CAD2nsn23UqshHz1ZUn8bHN0rWyOMbBHhn9V8pmCc4_aT_uGYaw@mail.gmail.com>
	<4F577D9B.7020402@gmail.com>
	<4F579A88.6030503@openwrt.org>
	<4F61F551.5010608@gmail.com>
	<4F639851.5080500@gmail.com>
	<4F674616.8080103@gmail.com>
	<CAD2nsn3xpkGenrK50YmE5D7Odg3sBEek5zKcLZF6MAm69p5RJg@mail.gmail.com>
	<4F674FF5.2060406@gmail.com>
	<4F6751B2.1030809@openwrt.org>
	<4F681B78.9000207@gmail.com>
	<CAD2nsn0d-3edYGH8u+v5mhrUZBMsznDNRDkDHE-tErG8uGk84Q@mail.gmail.com>
	<4F68235C.5090701@gmail.com>
	<CAD2nsn0toAjyWw48J7oREES0=x6D72hMntP+WpAjHmR5drd-tQ@mail.gmail.com>
	<4F682555.3020502@gmail.com>
	<20328.16366.166909.255035@gargle.gargle.HOWL>
	<CAD2nsn0JCKd4NnXOLfw4QXHTJdxrfepw9s6yYca=uSHwWXq3-A@mail.gmail.com>
	<CAD2nsn10svpDFkpbkCtFMGFdqW9G0syWrhL3s-ApQH2bKt0P2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Justin P. Mattock" <justinmattock@gmail.com>,
	Linux-wireless <linux-wireless@vger.kernel.org>,
	Felix Fietkau <nbd@openwrt.org>, linux-kernel@vger.kernel.org,
	Linux-netdev <netdev@vger.kernel.org>
To: Sujith Manoharan <c_manoha@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAD2nsn10svpDFkpbkCtFMGFdqW9G0syWrhL3s-ApQH2bKt0P2g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 20, 2012 at 4:45 PM, Mohammed Shafi
<shafi.wireless@gmail.com> wrote:
> On Tue, Mar 20, 2012 at 3:07 PM, Mohammed Shafi
> <shafi.wireless@gmail.com> wrote:
>> Hi Sujith/Justin,
>>
>> On Tue, Mar 20, 2012 at 1:59 PM, Sujith Manoharan
>> <c_manoha@qca.qualcomm.com> wrote:
>>> Justin P. Mattock wrote:
>>>> yeah this works:
>>>>
>>>> eading symbols from
>>>> /home/kernel/linux-next/drivers/net/wireless/ath/ath9k/ath9k.o...d=
one.
>>>> (gdb) l *(ath_tx_start+0x284)
>>>> 0xcad4 is in ath_tx_start (drivers/net/wireless/ath/ath9k/xmit.c:1=
878).
>>>> 1873 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ieee80211_is_data_qos(hdr-=
>frame_control)) {
>>>> 1874 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tidno =3D ieee80211_get_qo=
s_ctl(hdr)[0] &
>>>> 1875 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0IEEE80211_=
QOS_CTL_TID_MASK;
>>>> 1876 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tid =3D ATH_AN_2_TID(txctl=
->an, tidno);
>>>> 1877
>>>> 1878 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0WARN_ON(tid->ac->txq !=3D =
txctl->txq);
>>>> 1879 =A0 =A0 =A0 =A0 =A0}
>>>> 1880
>>>> 1881 =A0 =A0 =A0 =A0 =A0if ((tx_info->flags & IEEE80211_TX_CTL_AMP=
DU) && tid) {
>>>> 1882 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
>>>> (gdb)
>>>
>>> Can you try this patch ?
>>
>> just found out that 'ht_supported' may not =A0be set, if assoc respo=
nse
>> does not has ht_cap IE (or) if we could not parse it (why), then the
>> driver won't initialize those tid related structures ath_tx_node_ini=
t,
>> while we later access them in ath_tx_start. so this should fix the
>> issue.
>
> now i was able to quite easily recreate this issue in wireless testin=
g
> even without suspend resume and with the patch the issue seems to get
> fixed.
> i was using 2ghz channel 6 and TKIP (no HT!).

i was keep on trying with 5ghz TKIP and it seems HT enable even with
TKIP (need to see why this happens), thats why even i could not
recreate this issue. mac80211 seems to disable HT, ht_supported false
while in driver we go with ATH9K_HW_CAP HT


>
>
>>
>>>
>>> From: Sujith Manoharan <c_manoha@qca.qualcomm.com>
>>> Date: Tue, 20 Mar 2012 13:51:26 +0530
>>> Subject: [PATCH] ath9k: Use HW HT capabilites properly
>>>
>>> The commit "ath9k: Remove aggregation flags" changed how
>>> nodes were being initialized. Use the HW HT cap bits
>>> to initialize/de-initialize nodes, else we would be
>>> accessing an uninitialized entry during a suspend/resume cycle,
>>> resulting in a panic.
>>>
>>> Reported-by: Justin P. Mattock <justinmattock@gmail.com>
>>> Signed-off-by: Sujith Manoharan <c_manoha@qca.qualcomm.com>
>>> ---
>>> =A0drivers/net/wireless/ath/ath9k/main.c | =A0 =A04 ++--
>>> =A01 file changed, 2 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wi=
reless/ath/ath9k/main.c
>>> index 3879485..215eb25 100644
>>> --- a/drivers/net/wireless/ath/ath9k/main.c
>>> +++ b/drivers/net/wireless/ath/ath9k/main.c
>>> @@ -640,7 +640,7 @@ static void ath_node_attach(struct ath_softc *s=
c, struct ieee80211_sta *sta,
>>> =A0 =A0 =A0 =A0an->sta =3D sta;
>>> =A0 =A0 =A0 =A0an->vif =3D vif;
>>>
>>> - =A0 =A0 =A0 if (sta->ht_cap.ht_supported) {
>>> + =A0 =A0 =A0 if (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_HT) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ath_tx_node_init(sc, an);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0an->maxampdu =3D 1 << (IEEE80211_HT_=
MAX_AMPDU_FACTOR +
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 sta->ht_cap.ampdu_factor);
>>> @@ -659,7 +659,7 @@ static void ath_node_detach(struct ath_softc *s=
c, struct ieee80211_sta *sta)
>>> =A0 =A0 =A0 =A0an->sta =3D NULL;
>>> =A0#endif
>>>
>>> - =A0 =A0 =A0 if (sta->ht_cap.ht_supported)
>>> + =A0 =A0 =A0 if (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_HT)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ath_tx_node_cleanup(sc, an);
>>> =A0}
>>>
>>> --
>>> 1.7.9.4
>>>
>>
>>
>>
>> --
>> thanks,
>> shafi
>
>
>
> --
> thanks,
> shafi



--=20
thanks,
shafi
