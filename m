From: Felipe Contreras <felipe.contreras@gmail.com>
Subject: Re: [PATCH v2] mac80211: add assoc beacon timeout logic
Date: Mon, 11 Nov 2013 10:56:57 -0600
Message-ID: <CAMP44s0Lsd2qMf3a-Vx4=HTd_UxzLVC6q1bAGPr+t6anubNknA@mail.gmail.com>
References: <1384119945-31213-1-git-send-email-felipe.contreras@gmail.com>
	<1384160932.14334.6.camel@jlt4.sipsolutions.net>
	<CAMP44s3TFSgWuR8gVoFBznNP+t9mz+to===9i1PAnra4ogKu9w@mail.gmail.com>
	<1384184624.14334.31.camel@jlt4.sipsolutions.net>
	<CAMP44s2cVVe4-yW214B9hJu7n6M1onZpZaPCj5N0Fi1JWDKKsw@mail.gmail.com>
	<1384188067.14334.45.camel@jlt4.sipsolutions.net>
	<CAMP44s3nkj2wZYCPve7EhyeD7sEFmpUN=-h015dOP68PcNSTug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless Mailing List <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:49623 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753782Ab3KKQ46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 11:56:58 -0500
In-Reply-To: <CAMP44s3nkj2wZYCPve7EhyeD7sEFmpUN=-h015dOP68PcNSTug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 11, 2013 at 10:53 AM, Felipe Contreras
<felipe.contreras@gmail.com> wrote:
> On Mon, Nov 11, 2013 at 10:41 AM, Johannes Berg
> <johannes@sipsolutions.net> wrote:
>> On Mon, 2013-11-11 at 10:23 -0600, Felipe Contreras wrote:

>>> > This isn't really true like I said above - the kernel can only drop the
>>> > association, if userspace *insists* then it will try again and again.
>>>
>>> But it's not doing this:
>>>
>>>   ieee80211_destroy_assoc_data(sdata, false);
>>>   cfg80211_assoc_timeout(sdata->dev, bss);
>>>
>>> Which is what causes the association to stop for me.
>>>
>>> So where exactly in the code is the association being "dropped"?
>>
>> This does get called in my setup.
>
> Yes, because your setup is receiving beacons.
>
> Check the code:
>
> if ((ifmgd->assoc_data->need_beacon && !ifmgd->have_beacon) ||
>    ieee80211_do_assoc(sdata)) {
> struct cfg80211_bss *bss = ifmgd->assoc_data->bss;
>
> ieee80211_destroy_assoc_data(sdata, false);
> cfg80211_assoc_timeout(sdata->dev, bss);
> }
>
> If there's no beacon, cfg80211_assoc_timeout() is not called.
>
> I'm sure if you don't call ieee80211_rx_mgmt_beacon() at all you will
> see the same behavior I see.

My bad, actually the code that is not being called is:

  cfg80211_unlink_bss(local->hw.wiphy, assoc_data->bss);

In ieee80211_do_assoc().

-- 
Felipe Contreras
