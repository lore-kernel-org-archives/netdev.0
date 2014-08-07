From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] 6lowpan: Allow 6LoWPAN to be modular
Date: Thu, 7 Aug 2014 18:44:35 +0200
Message-ID: <CAMuHMdU214_aDNQBH=Nk6DZwsdCB3FQY1DY0ZQ8WQGQ86dGFUQ@mail.gmail.com>
References: <1407424003-15073-1-git-send-email-geert@linux-m68k.org>
	<ABE15994-F47B-4E4B-A6FC-79C6BCAC9FF3@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Aring <alex.aring@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net,
	BlueZ development <linux-bluetooth@vger.kernel.org>,
	linux-wpan@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ABE15994-F47B-4E4B-A6FC-79C6BCAC9FF3@holtmann.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcel,

On Thu, Aug 7, 2014 at 6:00 PM, Marcel Holtmann <marcel@holtmann.org> wrote:
>> Change config symbol 6LOWPAN from type bool to type tristate, so
>> 6LoWPAN can be built modular, just like IPV6
>>
>> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
>> ---
>> net/6lowpan/Kconfig | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/6lowpan/Kconfig b/net/6lowpan/Kconfig
>> index 028a5c6d1f61..e4a02ef55102 100644
>> --- a/net/6lowpan/Kconfig
>> +++ b/net/6lowpan/Kconfig
>> @@ -1,5 +1,5 @@
>> config 6LOWPAN
>> -     bool "6LoWPAN Support"
>> +     tristate "6LoWPAN Support"
>
> is this a regression from the previous CONFIG_6LOWPAN separation that we introduced? If it is, then it might be easiest if Dave just takes it into his net tree. Otherwise I take it through bluetooth-next.

I hadn't thought about that... Checking...

Yes, I believe this is a regression.

In v3.16, my allmodconfig build had:

CONFIG_IEEE802154_6LOWPAN=m
CONFIG_6LOWPAN_IPHC=m
CONFIG_BT_6LOWPAN=y

Without my patch it has:

CONFIG_6LOWPAN=y
CONFIG_IEEE802154_6LOWPAN=m
CONFIG_BT_6LOWPAN=m

and iphc is what's in net/6lowpan/built-in.o now.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
