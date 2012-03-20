From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: Re: ath: DMA failed to stop in 10 ms AR_CR=0x00000024 AR_DIAG_SW=0x02000020
 DMADBG_7=0x00008040
Date: Mon, 19 Mar 2012 23:27:40 -0700
Message-ID: <4F68235C.5090701@gmail.com>
References: <4F576FD5.2050208@gmail.com> <CAD2nsn23UqshHz1ZUn8bHN0rWyOMbBHhn9V8pmCc4_aT_uGYaw@mail.gmail.com> <4F577D9B.7020402@gmail.com> <4F579A88.6030503@openwrt.org> <4F61F551.5010608@gmail.com> <4F639851.5080500@gmail.com> <4F674616.8080103@gmail.com> <CAD2nsn3xpkGenrK50YmE5D7Odg3sBEek5zKcLZF6MAm69p5RJg@mail.gmail.com> <4F674FF5.2060406@gmail.com> <4F6751B2.1030809@openwrt.org> <4F681B78.9000207@gmail.com> <CAD2nsn0d-3edYGH8u+v5mhrUZBMsznDNRDkDHE-tErG8uGk84Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux-wireless <linux-wireless@vger.kernel.org>,
	Felix Fietkau <nbd@openwrt.org>, linux-kernel@vger.kernel.org,
	Linux-netdev <netdev@vger.kernel.org>
To: Mohammed Shafi <shafi.wireless@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAD2nsn0d-3edYGH8u+v5mhrUZBMsznDNRDkDHE-tErG8uGk84Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/19/2012 11:19 PM, Mohammed Shafi wrote:
>> (gdb) list *ath9k_tx+start+0x284
>> No symbol "start" in current context.
>
> hey, pls try l *(ath9k_tx_start+0x284), yesterday i did the same in
> the latest wireless testing tree it pointed to line 1929 of xmit.c
>
> sc->tx.seq_no +=0x10;
>
> also did few suspend/resume in my machine, nothing interesting happened
>
>>
>> before receiving the email to do the above code with gdb I had cleaned the
>> tree out with git clean -fx so rebuilding might have misalighned things(but
>> could be wrong)..
>>
>
>
>


seems gdb is not working with that code but works if I remove _start.
(maybe -next took this out or something)

(gdb) l *(ath9k_tx_start+0x284)
No symbol "ath9k_tx_start" in current context.
(gdb) l *(ath9k_tx+0x284)
0x4854 is in ath_paprd_activate (drivers/net/wireless/ath/ath9k/main.c:395).
390				continue;
391	
392			ar9003_paprd_populate_single_table(ah, caldata, chain);
393		}
394	
395		ar9003_paprd_enable(ah, true);
396		ath9k_ps_restore(sc);
397	}
398	
399	static bool ath_paprd_send_frame(struct ath_softc *sc, struct 
sk_buff *skb, int chain)

right now I am running next, will wait for the RX DMA to get a clean 
trace, then will look to see.. as for the other issue I just rebooted 
and hit this during bootup.

Justin P. Mattock
