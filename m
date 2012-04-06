From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: Re: ath: DMA failed to stop in 10 ms AR_CR=0x00000024 AR_DIAG_SW=0x02000020
 DMADBG_7=0x00008040
Date: Fri, 06 Apr 2012 09:40:20 -0700
Message-ID: <4F7F1C74.7080009@gmail.com>
References: <4F576FD5.2050208@gmail.com> <CAD2nsn23UqshHz1ZUn8bHN0rWyOMbBHhn9V8pmCc4_aT_uGYaw@mail.gmail.com> <4F577D9B.7020402@gmail.com> <4F579A88.6030503@openwrt.org> <4F61F551.5010608@gmail.com> <4F639851.5080500@gmail.com> <4F674616.8080103@gmail.com> <CAD2nsn3xpkGenrK50YmE5D7Odg3sBEek5zKcLZF6MAm69p5RJg@mail.gmail.com> <4F674FF5.2060406@gmail.com> <4F6751B2.1030809@openwrt.org> <4F681B78.9000207@gmail.com> <CAD2nsn0d-3edYGH8u+v5mhrUZBMsznDNRDkDHE-tErG8uGk84Q@mail.gmail.com> <4F68235C.5090701@gmail.com> <CAD2nsn0toAjyWw48J7oREES0=x6D72hMntP+WpAjHmR5drd-tQ@mail.gmail.com> <4F682555.3020502@gmail.com> <20328.16366.166909.255035@gargle.gargle.HOWL> <4F6FA388.9080408@gmail.com> <20337.9030.686697.228453@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mohammed Shafi <shafi.wireless@gmail.com>,
	Linux-wireless <linux-wireless@vger.kernel.org>,
	Felix Fietkau <nbd@openwrt.org>, linux-kernel@vger.kernel.org,
	Linux-netdev <netdev@vger.kernel.org>
To: Sujith Manoharan <c_manoha@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20337.9030.686697.228453@gargle.gargle.HOWL>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/26/2012 07:17 PM, Sujith Manoharan wrote:
> Justin P. Mattock wrote:
>> I would have to say this patch above does get rid of this crash I was
>> seeing. as a quick test I simply connect to a WPA network, then connect
>> to an open network going back and forth triggers this freeze for me
>> after applying this I am able to toggle back and forth without a freeze.
>
> Thanks for verifying.
>
> Sujith
>


 From going through the warning message I was playing around and am 
looking at: AH_UNPLUGGED .. seems if I remove this from the code I have 
not seen this warning message.
is there something wrong with AH_UNPLUGGED = 0x2 ?
is this the wrong address(0x2)?

the patch that I was using is:

 From ea8a7d6ecf8b0706f3f0521cd22cc359b20b9373 Mon Sep 17 00:00:00 2001
From: "Justin P. Mattock" <justinmattock@gmail.com>
Date: Sun, 25 Mar 2012 21:53:31 -0700
Subject: [PATCH] ath_test

Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>

---
  drivers/net/wireless/ath/ath9k/recv.c |    3 +--
  1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/recv.c 
b/drivers/net/wireless/ath/ath9k/recv.c
index f4ae3ba..d887cee 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -523,8 +523,7 @@ bool ath_stoprecv(struct ath_softc *sc)
  		sc->rx.rxlink = NULL;
  	spin_unlock_bh(&sc->rx.rxbuflock);

-	if (!(ah->ah_flags & AH_UNPLUGGED) &&
-	    unlikely(!stopped)) {
+	if (!(ah->ah_flags) && unlikely(!stopped)) {
  		ath_err(ath9k_hw_common(sc->sc_ah),
  			"Could not stop RX, we could be "
  			"confusing the DMA engine when we start RX up\n");
-- 
1.7.5.4


let me know what you think!

Justin P. Mattock
