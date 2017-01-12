From: Dan Williams <dcbw@redhat.com>
Subject: Re: To netlink or not to netlink, that is the question
Date: Thu, 12 Jan 2017 12:43:04 -0600
Message-ID: <1484246584.4651.3.camel@redhat.com>
References: <CAHmME9pkktqOSUyTS_XhgC-CE4iqTv6UEA6w74kkm3xnBY8z9g@mail.gmail.com>
         <20170112091440.7f6cd41f@xeon-e3>
         <CAHmME9rWDzO9j8E1HYSXY6j9FJqHODOYnEW8+SSggapDkQ_jBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37944 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751253AbdALSnH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 13:43:07 -0500
In-Reply-To: <CAHmME9rWDzO9j8E1HYSXY6j9FJqHODOYnEW8+SSggapDkQ_jBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-12 at 19:28 +0100, Jason A. Donenfeld wrote:
> On Thu, Jan 12, 2017 at 6:14 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> > It is up to you but I doubt that code with new private ioctl's will
> > be
> > accepted upstream. If you want full review then post for inclusion
> > upstream.
> > If you just want to maintain it is a private fork, go ahead and do
> > what
> > you want and suffer the consequences.
> 
> Obviously I'm going for upstream conclusion and not willing to
> "suffer
> the consequences", hence my email in the first place. Given that you
> seem most interested in netlink, might you have any constructive
> suggestions on how netlink might be used with very large atomic
> messages?

Typically kernel code doesn't pass very large atomic messages back and
forth.  From the description you mailed, I would guess a better fit API
would be to have specific netlink mechanisms for add/remove wgpeers,
and a specific mechanism for add/remove ipmasks for each peer.  And
don't forget netlink events to indicate when peers and ipmasks have
been added/removed, so userspace is aware of that.

Besides, perhaps multiple programs may wish to manipulate a wgdevice,
which could include adding/removing peers or ipmasks from separate
userspace processes.  That's not really possible with a huge buffer
that includes all the information, as a process would have to read the
buffer, update it, and send it back, which would then potentially
clobber whatever another process did between the read/write.

In short, if the API doesn't quite fit, then perhaps the API could be
broken up into smaller, more discrete operations that better fit the
netlink API.

Just some thoughts...

Dan
