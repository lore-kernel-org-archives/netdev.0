From: David Herrmann <dh.herrmann@gmail.com>
Subject: Re: [PATCH 2/4] mac80211: set NET_NAME_USER for user-space created ifs
Date: Thu, 27 Feb 2014 18:14:40 +0100
Message-ID: <CANq1E4TBeNbovfpVF1ByxostkNczdcK5R3c0jQ=qKp6V299kCg@mail.gmail.com>
References: <1393512434-1325-1-git-send-email-dh.herrmann@gmail.com>
	<1393512434-1325-3-git-send-email-dh.herrmann@gmail.com>
	<1393512787.4648.1.camel@jlt4.sipsolutions.net>
	<CANq1E4RNbtbdVhC2PgyZMGN_duScbmCOGeMxAYiKLL-8H=EWSA@mail.gmail.com>
	<1393517912.4648.5.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Tom Gundersen <teg@jklm.no>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393517912.4648.5.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

On Thu, Feb 27, 2014 at 5:18 PM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Thu, 2014-02-27 at 15:56 +0100, David Herrmann wrote:
>
>> >> +++ b/net/mac80211/iface.c
>> >> @@ -1620,6 +1620,7 @@ int ieee80211_if_add(struct ieee80211_local *local, const char *name,
>> >>                                       + IEEE80211_ENCRYPT_HEADROOM;
>> >>               ndev->needed_tailroom = IEEE80211_ENCRYPT_TAILROOM;
>> >>
>> >> +             ndev->name_assign_type = NET_NAME_USER;
>> >
>> > this is wrong because we call this in main.c with a "wlan%d" argument
>> > for the name, which gets expanded.
>>
>> Whoops, yeah, same issue as with ath6kl where I fixed it with a
>> separate "name_assign_type" argument. I will do the same here for v2.
>
> I'm not sure that helps - the user could potentially pass "foobar%d" as
> the interface name and get a number assigned by the kernel. In that case
> you probably *don't* want to set it to "name assigned by user"?
>
> Maybe this whole thing can just be handled in __dev_alloc_name() since
> no kernel user should pass just a string without "%d" in it.

Nope, I still want to set NET_NAME_USER in that case. It's not about
the %d suffix, it's about who chooses the suffix. If wpas decides to
use p2p-wlanX-%d, this is fine, as it's a virtual device where stable
IDs are not required at all.

Thanks
David
