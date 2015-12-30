From: Bjorn Andersson <bjorn-UYDU3/A3LUY@public.gmane.org>
Subject: Re: [PATCH] mac80211: Make addr const in SET_IEEE80211_PERM_ADDR()
Date: Wed, 30 Dec 2015 12:01:53 -0800
Message-ID: <CAJAp7OisPmCGbMUjjAR_30TLXD1Wm_gOMRp-xfXWEVz-R2yUOA@mail.gmail.com>
References: <1450946006-7498-1-git-send-email-bjorn.andersson@sonymobile.com>
	<CAFqt6zam7maK4wFrKo=yqWxaBkVDJhZGbKAFAdmcZPQonXTcxA@mail.gmail.com>
	<CAJAp7Oinz993CQgA81SifcJoeHicD9YNhBv0HHkiav3rD5=M4Q@mail.gmail.com>
	<CAFqt6zYfQwBN1in2dwYRY6CE1vf9-Kznc0z5UhBGxJzvEs7-kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Souptick Joarder <jrdr.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAFqt6zYfQwBN1in2dwYRY6CE1vf9-Kznc0z5UhBGxJzvEs7-kw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 30, 2015 at 10:30 AM, Souptick Joarder <jrdr.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Wed, Dec 30, 2015 at 10:35 PM, Bjorn Andersson <bjorn-UYDU3/A3LUY@public.gmane.org> wrote:
>> On Wed, Dec 30, 2015 at 8:47 AM, Souptick Joarder <jrdr.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>>
>>> HI Bjorn,
>>>
>>> On Thu, Dec 24, 2015 at 2:03 PM, Bjorn Andersson <bjorn-UYDU3/A3LUY@public.gmane.org> wrote:
>>> > Make the addr parameter const in SET_IEEE80211_PERM_ADDR() to save
>>> > clients from having to cast away a const qualifier.
>>> >
>>> > Signed-off-by: Bjorn Andersson <bjorn.andersson-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org>
>>> > ---
>>> >  include/net/mac80211.h | 2 +-
>>> >  1 file changed, 1 insertion(+), 1 deletion(-)
>>> >
>>> > diff --git a/include/net/mac80211.h b/include/net/mac80211.h
>>> > index 7c30faff245f..a6f3c9c4b7c2 100644
>>> > --- a/include/net/mac80211.h
>>> > +++ b/include/net/mac80211.h
>>> > @@ -2167,7 +2167,7 @@ static inline void SET_IEEE80211_DEV(struct ieee80211_hw *hw, struct device *dev
>>> >   * @hw: the &struct ieee80211_hw to set the MAC address for
>>> >   * @addr: the address to set
>>> >   */
>>> > -static inline void SET_IEEE80211_PERM_ADDR(struct ieee80211_hw *hw, u8 *addr)
>>> > +static inline void SET_IEEE80211_PERM_ADDR(struct ieee80211_hw *hw, const u8 *addr)
>>>
>>> I guess without const or with const doesn't make much difference here.
>>> Correct me if I am wrong.
>>
>> For most cases it doesn't make any difference, but in my driver I
>> acquire the mac address as a const u8 *. Therefor I need to cast away
>> the const part when calling this API.
>>
>> There's an existing example of this in
>> drivers/net/wireless/st/cw1200/main.c line 601.
>
> Is the path correct ? I think path is
> drivers/net/wireless/cw1200/main.c line 334
>

It's apparently being relocated in linux-next, and I'm not sure where
I got that line number from. But that's the example I tried to refer
to ;)

Sorry about that.

Regards,
Bjorn

>> I think it's safe to assume that this API won't ever modify the passed
>> addr buffer, so there would be no future issues of marking the
>> parameter const either.
>
> I agree with you.
>
>>
>>>
>>> >  {
>>> >         memcpy(hw->wiphy->perm_addr, addr, ETH_ALEN);
>>> >  }
>>>
>>
>> Regards,
>> Bjorn
>
> -Souptick
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
