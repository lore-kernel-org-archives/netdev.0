From: Andy Green <andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 6/7] net: wireless: wcn36xx: remove powersaving for wcn3620
Date: Tue, 10 Feb 2015 05:28:01 +0800
Message-ID: <CAAfg0W58Wssa=OKRSGtxY4rQJCzP0uTw__Rd278fc1v7Q0fqUw@mail.gmail.com>
References: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
	<20150118051111.31866.39208.stgit@114-36-241-182.dynamic.hinet.net>
	<CAJAp7OhcFTuYfc7JOKW1SrVRbucuSWg5jcFaoVnSDgBxsyo2ng@mail.gmail.com>
	<CAAfg0W6dPupGLgwDF5FtNqEFvC4Y+GvFBAmXWcUQwXr2y6KugQ@mail.gmail.com>
	<CAJAp7OjLDCzLYeb3LHNs1sOHWM64XZWzr46UQ2vNirH_2JibNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	wcn36xx <wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Bjorn Andersson <bjorn-UYDU3/A3LUY@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJAp7OjLDCzLYeb3LHNs1sOHWM64XZWzr46UQ2vNirH_2JibNg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10 February 2015 at 05:11, Bjorn Andersson <bjorn-UYDU3/A3LUY@public.gmane.org> wrote:
> On Feb 9, 2015 1:07 PM, "Andy Green" <andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> wrote:
>>
>> On 10 February 2015 at 01:54, Bjorn Andersson <bjorn-UYDU3/A3LUY@public.gmane.org> wrote:
>> > On Sat, Jan 17, 2015 at 9:11 PM, Andy Green <andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
>> > wrote:
>> >> WCN3620 powersaving mode is not stable.  Disable it if we're
>> >> on a wcn3620 chip type.
>> >>
>> >> Signed-off-by: Andy Green <andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
>> >> ---
>> >>  drivers/net/wireless/ath/wcn36xx/main.c |    4 ++++
>> >>  1 file changed, 4 insertions(+)
>> >>
>> >> diff --git a/drivers/net/wireless/ath/wcn36xx/main.c
>> >> b/drivers/net/wireless/ath/wcn36xx/main.c
>> >> index c4178c7..569d45b 100644
>> >> --- a/drivers/net/wireless/ath/wcn36xx/main.c
>> >> +++ b/drivers/net/wireless/ath/wcn36xx/main.c
>> >> @@ -924,6 +924,10 @@ static int wcn36xx_init_ieee80211(struct wcn36xx
>> >> *wcn)
>> >>                 IEEE80211_HW_AMPDU_AGGREGATION |
>> >>                 IEEE80211_HW_TIMING_BEACON_ONLY;
>> >>
>> >> +       /* 3620 powersaving currently unstable */
>> >> +       if (wcn->chip_version == WCN36XX_CHIP_3620)
>> >> +               wcn->hw->flags &= ~IEEE80211_HW_SUPPORTS_PS;
>> >> +
>> >
>> > Hi Andy,
>> >
>> > I have the same problem (Data Abort Exception in wcnss) on 3680, this
>> > with my wip smd code and a hacked up remoteproc-pil. I haven't spent
>> > any effort on debugging this, but it looks like it's something related
>> > to what we have ported to mainline (or lack thereof) rather than a
>> > 3620 specific issue.
>>
>> Makes sense since I only have 3620, I assumed it's related to that.
>>
>> However he can work for a while with powersaving on, but ping
>> latencies are +600-800ms and he's shaky.
>>
>> Later I found something mac80211 generic scan preparation or post-scan
>> code (for scan initiated by wpa_supplicant) is able to stop wlan
>> traffic after a few goes even if the actual scan mode smd is not sent.
>>
>> At that point I think a nice solution would be a donation of time from
>> guys who specialize in wcn for a living to come and hand out a pony or
>> two...
>>
>
> I agree, my goal is that we get this running in mainline (smd, smsm, smp2p
> and remoteproc-tz) so that people with the domain knowledge can go in and
> make it work well.

Sounds great thanks.

I also tried hostapd which is fully workable without encryption, plus
or minus the instabilities mentioned.  But for wpa, he chokes trying
to inject a packet.  So it's another pony needed from somewhere.

Can I ask if smdtty will also appear?  I uplevelled and hacked smdtty
a bit from a 3.10 reference tree for 8916-qrd, and I was able to get
wcn3620 BT working stably for BT keyboard + mouse and even ad2p.

However the hack bound together smdtty ch2 + 3 in smdtty driver and
made it understand about the missing hci protocol byte... this is far
from reasonable for upstream, but it works like the 3.10 except needs
no special bluez / userland treatment.  So I'm curious if no smdtty
how the split smd hci / acl link in firmware will appear coherently to
userspace as a normal uart.

-Andy

> Regards,
> Bjorn
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
