From: Felipe Contreras <felipe.contreras-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2] mac80211: add assoc beacon timeout logic
Date: Mon, 11 Nov 2013 05:01:11 -0600
Message-ID: <CAMP44s3xycqUAxvporp6cmjCqyXg_T07Ee5zKUpnhdQGUhsmLQ@mail.gmail.com>
References: <1384119945-31213-1-git-send-email-felipe.contreras@gmail.com>
	<CABPxzY+MkosJBeQdBFV3u5X=e5io3qKeb6sqd8Fn89awMc2vuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Krishna Chaitanya <chaitanya.mgit-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CABPxzY+MkosJBeQdBFV3u5X=e5io3qKeb6sqd8Fn89awMc2vuA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 11, 2013 at 12:41 AM, Krishna Chaitanya
<chaitanya.mgit-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Mon, Nov 11, 2013 at 3:15 AM, Felipe Contreras
> <felipe.contreras-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> We don't want to be waiting forever for a beacon that will never come,
>> just continue the association.
>>
>> Signed-off-by: Felipe Contreras <felipe.contreras-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>>
>> The previous version depended on some cleanup patches, plus had some unclear
>> rerun logic.
>>
>>  net/mac80211/ieee80211_i.h |  1 +
>>  net/mac80211/mlme.c        | 32 ++++++++++++++++++++++++++------
>>  2 files changed, 27 insertions(+), 6 deletions(-)
>>
>> diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
>> index 611abfc..e1f858d 100644
>> --- a/net/mac80211/ieee80211_i.h
>> +++ b/net/mac80211/ieee80211_i.h
>> @@ -358,6 +358,7 @@ struct ieee80211_mgd_assoc_data {
>>         const u8 *supp_rates;
>>
>>         unsigned long timeout;
>> +       unsigned long beacon_timeout;
>>         int tries;
>>
>>         u16 capability;
>> diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
>> index 86e4ad5..68f76f7 100644
>> --- a/net/mac80211/mlme.c
>> +++ b/net/mac80211/mlme.c
>> @@ -38,6 +38,7 @@
>>  #define IEEE80211_ASSOC_TIMEOUT                (HZ / 5)
>>  #define IEEE80211_ASSOC_TIMEOUT_LONG   (HZ / 2)
>>  #define IEEE80211_ASSOC_TIMEOUT_SHORT  (HZ / 10)
>> +#define IEEE80211_ASSOC_BEACON_TIMEOUT 2 * HZ
>
> Don't you think its too long? 3-4 beacon intervals should suffice.

I don't have an opinion, if you think that's better, that's fine by me.

-- 
Felipe Contreras
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
