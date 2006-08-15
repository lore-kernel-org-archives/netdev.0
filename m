From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: proposal for new wireless configuration API
Date: Tue, 15 Aug 2006 12:14:17 -0400
Message-ID: <43e72e890608150914v3b831c18sea283aa26528553b@mail.gmail.com>
References: <1155655728.17742.30.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Jean Tourrilhes" <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:26562 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S965382AbWHOQOS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 12:14:18 -0400
Received: by nf-out-0910.google.com with SMTP id x30so374940nfb
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2006 09:14:17 -0700 (PDT)
To: "Johannes Berg" <johannes@sipsolutions.net>
In-Reply-To: <1155655728.17742.30.camel@ux156>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This all sounds good to me. A few comments here, to give you something
to read when you get home.

On 8/15/06, Johannes Berg <johannes@sipsolutions.net> wrote:

>  - we implement a bunch of commands, for example NL80211_CMD_INJECT and
>    _SETATTR, _GETATTR[(attrnumber)] [easy with dumpit()],
>    _GETATTRGROUP, ...

Basically redo WE completely from scratch using netlink.

>  - we have a whole bunch of possible attributes:
>    NL80211_ATTR_FLAGS: flags for injecting a packet (e.g. want_notify)

For per packet this makes sense, for modification of all packets I
think configfs would be more suitable. Then again this is just an
addition, I'm not disagreeing here with the approach. The same goes
for several common wireless settings -- we could also have a configfs
directory for each device which would allow manual read/writing for
setting/getting certain values; mind you that congifs does allow for
setting/getting multiple values at the same time, for those of you who
have wondered. This could just could easily go in as a wrapper for
configfs->new NL API.

>    NL80211_ATTR_IFINDEX: index of interface to use
>    (NL80211_ATTR_PHYIDX: (later) index of wiphy to configure)

Do you mean to have a wireless device have its own device index,
separate from the netdevice index? Can you elaborate a bit on this?

>    NL80211_ATTR_ESSID,
>                 FRAGTHRESHOLD,
>                 CHANNEL,...: most of the old wext ioctls map to
>                              attributes now

With WE we were restricted to the number of attributes possibly
changed by the number of ioctls and later by sub-ioctl hack
restrictions. What restrictions are we to face with this? Do we want
to map each attribute directly to the respective WE ioctl number to
make it easy to do backward compatibility?

  Luis
