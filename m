From: Mohammed Shafi <shafi.wireless@gmail.com>
Subject: Re: ath: DMA failed to stop in 10 ms AR_CR=0x00000024
 AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
Date: Tue, 20 Mar 2012 13:14:40 +0530
Message-ID: <CAD2nsn2b9yVrX16m4Pc0F96PHF09ySv8ncY8Qnr7_9CC8hrbtA@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=f46d0434bf42eec20c04bba7d864
Cc: Linux-wireless <linux-wireless@vger.kernel.org>,
	Felix Fietkau <nbd@openwrt.org>, linux-kernel@vger.kernel.org,
	Linux-netdev <netdev@vger.kernel.org>
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F682555.3020502@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--f46d0434bf42eec20c04bba7d864
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

> /home/kernel/linux-next/drivers/net/wireless/ath/ath9k/ath9k.o...done.
> (gdb) l *(ath_tx_start+0x284)
> 0xcad4 is in ath_tx_start (drivers/net/wireless/ath/ath9k/xmit.c:1878).
> 1873 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ieee80211_is_data_qos(hdr->fr=
ame_control)) {
> 1874 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tidno =3D ieee80211_get_qos_c=
tl(hdr)[0] &
> 1875 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0IEEE80211_QOS=
_CTL_TID_MASK;
> 1876 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tid =3D ATH_AN_2_TID(txctl->a=
n, tidno);
> 1877
> 1878 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0WARN_ON(tid->ac->txq !=3D txc=
tl->txq);
> 1879 =A0 =A0 =A0 =A0 =A0 =A0}
> 1880
> 1881 =A0 =A0 =A0 =A0 =A0 =A0if ((tx_info->flags & IEEE80211_TX_CTL_AMPDU)=
 && tid) {
> 1882 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> (gdb

please check with the attached debug patch if tid is 'NULL'


its my theory that tid is not initialized in ath_tx_node_init just after re=
sume.
during suspend ath9k_sta_remove may be called
ieee80211_suspend -> drv_sta_state ->
drv_sta_remove->ath9k_sta_remove->ath_node_detach->ath_tx_node_cleanup

during resume

ieee80211_resume ->
ieee80211_reconfig->drv_sta_state->ath9k_sta_add->ath_node_attach->ath_tx_n=
ode_init

now sta.ht_cap.ht_supported should be true. it will be set to true in
assoc_sucess path and then sta_add is called.

let me see if i had missed something or my analysis itself is wrong.

>



--=20
thanks,
shafi

--f46d0434bf42eec20c04bba7d864
Content-Type: text/x-diff; charset=US-ASCII; name="debug-panic.patch"
Content-Disposition: attachment; filename="debug-panic.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h00n0nbr0

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3dpcmVsZXNzL2F0aC9hdGg5ay94bWl0LmMgYi9kcml2
ZXJzL25ldC93aXJlbGVzcy9hdGgvYXRoOWsveG1pdC5jCmluZGV4IDgzNGU2YmMuLmViMjIxNTYg
MTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L3dpcmVsZXNzL2F0aC9hdGg5ay94bWl0LmMKKysrIGIv
ZHJpdmVycy9uZXQvd2lyZWxlc3MvYXRoL2F0aDlrL3htaXQuYwpAQCAtMTg3NSw2ICsxODc1LDEy
IEBAIHN0YXRpYyB2b2lkIGF0aF90eF9zdGFydF9kbWEoc3RydWN0IGF0aF9zb2Z0YyAqc2MsIHN0
cnVjdCBza19idWZmICpza2IsCiAJCQlJRUVFODAyMTFfUU9TX0NUTF9USURfTUFTSzsKIAkJdGlk
ID0gQVRIX0FOXzJfVElEKHR4Y3RsLT5hbiwgdGlkbm8pOwogCisJCWlmICghdGlkKSB7CisJCQlw
cmludGsoIlxudGlkIGlzIE5VTEwhISEiKTsKKwkJCXJldHVybjsKKwkJfQorCisKIAkJV0FSTl9P
Tih0aWQtPmFjLT50eHEgIT0gdHhjdGwtPnR4cSk7CiAJfQogCg==
--f46d0434bf42eec20c04bba7d864--
