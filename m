From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: pull-request: mac80211 2017-10-16
Date: Tue, 17 Oct 2017 07:46:21 +0200
Message-ID: <1508219181.10607.45.camel@sipsolutions.net>
References: <20171016134618.30810-1-johannes@sipsolutions.net>
         <CAHmME9rHMMAgJs3uQYpt15V8eh-PjDqioqURA3KPKEhc2a9OEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Jason A. Donenfeld" <Jason-OnJsPKxuuEcAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHmME9rHMMAgJs3uQYpt15V8eh-PjDqioqURA3KPKEhc2a9OEg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-10-17 at 01:30 +0200, Jason A. Donenfeld wrote:
> Mobile phone right now, so not able to write patch, but you probably
> should be using crypto_memneq for comparing those two keys, not
> memcmp.

I know that's a gut instinct, but I really don't see the point.

If you actually get this to evaluate to "equal", you're already being
attacked, and the attacker already knows they're trying to get the same
key to be installed again. If it's not equal, you execute so much code
beneath, going to the driver etc., that I'd think this particular time
is in the noise.

Also, this isn't something that the attacker can directly observe
anyway, and if they can, then surely the fact that we *skip* a large
amount of code when returning 0 is also observable.

Besides, the only thing that can observe the timing is hostapd or
wpa_supplicant, which obviously know the key (and in the fixed versions
will already have done the comparison themselves).

And lastly, if you wanted to use this as an oracle to get the key back
from the kernel, then you already have admin permissions (in your
network namespace), and can just sniff netlink traffic anyway.

johannes
