From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: [PATCH 4/5] mac80211: Add more ethtools stats: survey, rates,
 etc
Date: Thu, 12 Apr 2012 13:46:08 -0700
Message-ID: <4F873F10.6010207@candelatech.com>
References: <1334248375-22967-1-git-send-email-greearb@candelatech.com>  <1334248375-22967-5-git-send-email-greearb@candelatech.com>  <4F8705E3.2010902@openwrt.org> <4F870828.4020708@candelatech.com> <1334259053.2497.18.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1334259053.2497.18.camel-/LGg1Z1CJKReKY3V0RtoKmatzQS1i7+A3tAM5lWOD0I@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/12/2012 12:30 PM, Ben Hutchings wrote:
> On Thu, 2012-04-12 at 09:51 -0700, Ben Greear wrote:
>> On 04/12/2012 09:42 AM, Florian Fainelli wrote:
>>> Hi,
>>>
>>> Le 04/12/12 18:32, greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org a =C3=A9crit :
>>>> From: Ben Greear<greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
>>>>
>>>> The signal and noise are forced to be positive since ethtool
>>>> deals in unsigned 64-bit values and this number should be human
>>>> readable. This gives easy access to some of the data formerly
>>>> exposed in the deprecated /proc/net/wireless file.
>>>
>>> Uh, that's misleading, the signal and noise values are typically ne=
gative, so one needs to think about mentally adding a minus sign if he/=
she wants to
>>> understand it. Does not ethtool know about 32-bits signed integers?
>>
>> Ethtool stats only supports u64.  I think it's easy enough for
>> humans or programs to add the negative sign.  Can signal or noise
>> ever be>  0?  If so, that could actually break something that depend=
s
>> on flipping the value to negative....
>
> So far as I can see, the ethtool stats were expected to be counters,
> which obviously cannot become negative (or fractional).  Maybe it's t=
ime
> to define another command and string-set to cover other types of stat=
us
> information.  The ethtool utility could ask for those typed statistic=
s
> as well, so 'ethtool -S' would get all of them.

One nice thing about ethtool stats API is that it is backwards and forw=
ards
compatible for a long while.  Also, adding a new API means a second cal=
l
into the kernel (most likely) for the other set of strings, which effec=
tively
doubles the cost of getting stats (and allows the stats to be updated
out-of-sync with each other more easily).

I wonder if instead we could add a convention where we add a short
prefix (or suffix) to a string to denote it's type (and cast the value
into u64).  So, an old ethtool might see:

foo:s32: 4294967295

while a new one understand that the s32: prefix is special, do
some casting, and could show:
foo: -1

Both are still at least somewhat human readable, and probably wouldn't
confuse anyone that is parsing the output of existing ethtool output.

Thanks,
Ben


--=20
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
