From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH] Revert "ipw2200: select CFG80211_WEXT"
Date: Mon, 5 Jan 2015 11:14:52 +0100
Message-ID: <54AA641C.7050307@broadcom.com>
References: <1420297188.2397.3.camel@tiscali.nl>	 <CD467A59-F563-439B-BA82-954AB27AD9CC@holtmann.org>	 <CA+55aFzYSiUkntraMrHEhMzkt35Ft2p9E3cT7ejwQOBDwKvcOg@mail.gmail.com> <1420324124.9624.60.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	"Kalle Valo" <kvalo@codeaurora.org>, Jiri Kosina <jkosina@suse.cz>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420324124.9624.60.camel@x220>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/03/15 23:28, Paul Bolle wrote:
> On Sat, 2015-01-03 at 10:07 -0800, Linus Torvalds wrote:
>> On Sat, Jan 3, 2015 at 10:02 AM, Marcel Holtmann<marcel@holtmann.org>  wrote:
>>>
>>> why would you revert this? It is obviously the correct change to actually select CFG80211_WEXT.
>>
>> I don't know about obvious, but yeah, I think the select in this case
>> is actually the better idea anyway.
>
> Obviously it wasn't obvious to me!
>
> My reasoning was that the "ipw2200: select CFG80211_WEXT" commit was
> _solely_ a workaround for the breakage introduced by that other patch.
> And since that one is now reverted the workaround wasn't needed anymore.
>
> Besied, I thought we try to avoid select-ing symbols that can also be
> set manually. As that makes it more likely to trigger circular
> dependency problems in the kconfig tools, doesn't it?
>
>> We could make the CFG80211_WEXT help message be very negative so that
>> people aren't encouraged to select it even if they can, but then if
>> they need the ipw driver it gets selected because of that. Because the
>> ipw driver is probably the more important of the two if you just
>> happen to have old hardware but are upgrading yout software (and
>> anybody who recompiles their own kernel is obviously doing the
>> latter).
>
> Side note: am I correct in thinking that there's some successor to
> CFG80211_WEXT and that the ipw2200 driver could, at least in theory, be
> ported to that successor? (ipw2200 hardware appears to be a bit old, so
> probably no one would care enough to actually do that.)
> net/wireless/kconfig doesn't mention anything like that, so probably I'm
> just confused.

ipw2200 is a WEXT driver using some wext functionality (and struct 
wiphy) provided by cfg80211 hence it needs CFG80211_WEXT. I guess that 
is what makes it confusing.

Regards,
Arend


> Paul Bolle
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
