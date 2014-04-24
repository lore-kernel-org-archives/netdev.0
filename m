From: "Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>
Subject: Re: [Linux-zigbee-devel] [PATCH] 6lowpan: nuke net_ieee802154_lowpan()
 accessor when 6lowpan is disabled
Date: Thu, 24 Apr 2014 10:57:44 -0700
Message-ID: <CAB=NE6XQaeyBAqtjneUKqLS-na6ftNY5a22dw2XFQSsOBD1TQA@mail.gmail.com>
References: <1398193438-23805-1-git-send-email-mcgrof@do-not-panic.com>
 <20140424164445.GA4675@omega> <CAB=NE6XS9-Zu9sb5geO2WTnnvv6KqyT+QnL5bRf1fiRx3=ocrg@mail.gmail.com>
 <20140424173333.GA21799@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"backports-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <backports-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <backports-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140424173333.GA21799@omega>
Sender: backports-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 24, 2014 at 10:33 AM, Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Hi Luis,
>
> On Thu, Apr 24, 2014 at 10:25:58AM -0700, Luis R. Rodriguez wrote:
>> On Thu, Apr 24, 2014 at 9:44 AM, Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> > Hi,
>> >
>> > On Tue, Apr 22, 2014 at 12:03:58PM -0700, Luis R. Rodriguez wrote:
>> >> From: "Luis R. Rodriguez" <mcgrof-IBi9RG/b67k@public.gmane.org>
>> >>
>> >> Johannes noted this is not needed, all of the fragment
>> >> accessors don't need CONFIG_NET_NS. This goes test compiled with
>> >> CONFIG_BT_6LOWPAN=y and a disabled CONFIG_NET_NS.
>> >>
>> >
>> > a little note about this here. There exists two 6LoWPAN standard. One
>> > for bluetooth low energy and one for IEEE 802.15.4.
>> >
>> > The actual namespace is only for IEEE 802.15.4, because we need
>> > fragmentation there. 6LoWPAN fragmentation for bluetooth low energy is
>> > already handled by the MAC-Layer. So this has nothing to do with
>> > CONFIG_BT_6LOWPAN.
>>
>> Thanks for the clarification, I actually did mean
>> CONFIG_IEEE802154_6LOWPAN however, I goofed that on the commit log.
>>
>
> ok. But I need to say thanks for sending this patch! :-)
>
> It's nice to see that the community helps to improving the code which I
> produced and it's really not perfect at the moment. (I was a little bit
> shocked that somebody makes the effort to making a backport about that).

To be clear -- we strive for automatic backport for the entire Linux
kernel, so the way this should be seen is that if something gets added
to Linux it will eventually get backported automatically. We're not
there yet to scale rapid integration of most used drivers but that is
a lofty objective. In this case what triggered the backport was that
Hauke orginally had added backport support for CONFIG_IEEE802154, when
6 Lowpan was merged upstream we took that in as well, that required a
few changes to help with the automatic backport, and I'm glad these
have gone in now. I should also note that I haven't personally tested
the 6lowpan backport but reports from users on the backport with
IEEE802154 or 6lowpan would be greatly appreciated, typically for
backports the way it works is if things compile it should work as the
backports code only consists of about 1% of the code used and bugs
have been infrequent on that codebase. Since 6lowpan is ever changing,
as noted in earlier threads, folks can use the latest linux-next based
backports release, this is listed on the temporary backports release
page [0].

[0] http://drvbp1.linux-foundation.org/~mcgrof/rel-html/backports/

  Luis
