From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH net-next v9 2/9] net: nl80211 - make rdev_add_virtual_intf
 take name_assign_type
Date: Thu, 17 Jul 2014 11:16:56 +0200
Message-ID: <CAG-2HqWGVqNFJGeh_Uj2pbC-+m8tsHeeO=f_3MD8JMcTDvpDDw@mail.gmail.com>
References: <1405584370-30054-1-git-send-email-teg@jklm.no>
 <1405584370-30054-3-git-send-email-teg@jklm.no> <1405587855.20120.0.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	John Linville <linville@tuxdriver.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405587855.20120.0.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 17, 2014 at 11:04 AM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Thu, 2014-07-17 at 10:06 +0200, Tom Gundersen wrote:
>> Pass the value down and set it at the same place the name itself is set.
>
> Huh? What's this? Can you explain why?

Sure, sorry the context got lost.

We want to expose the origin of ifnames so that udev can better decide
whether or not to rename them. In particular, this patch will allow
udev to tell that it should no longer rename Wifi-P2P devices, which
is currently a problem.

A general overview is in the patch introducing the interface:
<http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=685343fc3ba61a1f6eef361b786601123db16c28>.

>>  static struct wireless_dev *ath6kl_cfg80211_add_iface(struct wiphy *wiphy,
>>                                                     const char *name,
>> +                                                   unsigned char name_assign_type,
>
> unsigned char for an enum is really odd.

Hm, this was based on the addr_assign_type attribute, which also is an
unsigned char (and serves a very similar purpose).

Out of interest, what would you have preferred (and why)?

Cheers,

Tom
