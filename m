From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: To netlink or not to netlink, that is the question
Date: Fri, 13 Jan 2017 08:17:10 +0100
Message-ID: <1484291830.19860.3.camel@sipsolutions.net>
References: <CAHmME9pkktqOSUyTS_XhgC-CE4iqTv6UEA6w74kkm3xnBY8z9g@mail.gmail.com>
         <20170112091440.7f6cd41f@xeon-e3>
         <CAHmME9rWDzO9j8E1HYSXY6j9FJqHODOYnEW8+SSggapDkQ_jBA@mail.gmail.com>
         <1484246584.4651.3.camel@redhat.com>
         <CAHmME9oYDdQGsQ8jQGJMeJ-0A6O+Och+Y+5Q_=Q=M9qgrxDq2Q@mail.gmail.com>
         (sfid-20170112_200222_564116_D34FB2DF)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Netdev <netdev@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:49056 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751108AbdAMHRR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Jan 2017 02:17:17 -0500
In-Reply-To: <CAHmME9oYDdQGsQ8jQGJMeJ-0A6O+Och+Y+5Q_=Q=M9qgrxDq2Q@mail.gmail.com> (sfid-20170112_200222_564116_D34FB2DF)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-12 at 20:02 +0100, Jason A. Donenfeld wrote:
> Hi Dan,
> 
> Thanks for your response. I'd thought about this, at least for
> adding/removing wgpeers/wgipmasks and for configuring wgdevices. This
> would fit into multiple smaller messages indeed.
> 
> But what about fetching the list of all existing peers and ipmasks
> atomically? It seems like with multiple calls, if I'm using some kind
> of pagination, things could change in the process. That's why using
> one big buffer was most appealing... Any ideas about this?

In addition to what others have said - netlink typically includes (and
has helpers to do so) a generation counter that's updated whenever this
list changes, and included in each message, so if userspace really
cares (often not) it can retry the dump until the system was idle
enough to get a consistent snapshot.

It also looks to me like your existing API isn't even compat-safe due
to u64 alignment (e.g. in wgpeer), proving once again that ioctl is a
bad idea.

johannes
