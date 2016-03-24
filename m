From: Tolga Ceylan <tolga.ceylan@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Wed, 23 Mar 2016 22:10:06 -0700
Message-ID: <CALmu+SwjG0GVocGufTbgX-WJfcsP85SvHB=xtW7qQX3kZwJCxg@mail.gmail.com>
References: <1450203712.8474.46.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151215194410.GB3187@1wt.eu>
	<1450214475.8474.50.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151216073814.GA3373@1wt.eu>
	<20151216161514.GA3476@1wt.eu>
	<CAO5YkUSL=k3UxmuqkGN666YSvH-=UGKCZvRgqqBnnr1EPRqRtw@mail.gmail.com>
	<20151218185812.GD4448@1wt.eu>
	<1450492683.8474.123.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151219070009.GA4634@1wt.eu>
	<CALx6S35248apbWqtG+g2U99O=4UJqyAG0bJeuxhZWtShrpDF+w@mail.gmail.com>
	<20151221204127.GC8018@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, cgallek@google.com,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35692 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbcCXFKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 01:10:07 -0400
Received: by mail-io0-f195.google.com with SMTP id 124so8162941iov.2
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 22:10:07 -0700 (PDT)
In-Reply-To: <20151221204127.GC8018@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 21, 2015 at 12:41 PM, Willy Tarreau <w@1wt.eu> wrote:
> On Mon, Dec 21, 2015 at 12:38:27PM -0800, Tom Herbert wrote:
>> On Fri, Dec 18, 2015 at 11:00 PM, Willy Tarreau <w@1wt.eu> wrote:
>> > On Fri, Dec 18, 2015 at 06:38:03PM -0800, Eric Dumazet wrote:
>> >> On Fri, 2015-12-18 at 19:58 +0100, Willy Tarreau wrote:
>> >> > Hi Josh,
>> >> >
>> >> > On Fri, Dec 18, 2015 at 08:33:45AM -0800, Josh Snyder wrote:
>> >> > > I was also puzzled that binding succeeded. Looking into the code paths
>> >> > > involved, in inet_csk_get_port, we quickly goto have_snum. From there, we end
>> >> > > up dropping into tb_found. Since !hlist_empty(&tb->owners), we end up checking
>> >> > > that (tb->fastreuseport > 0 && sk->sk_reuseport && uid_eq(tb->fastuid, uid)).
>> >> > > This test passes, so we goto success and bind.
>> >> > >
>> >> > > Crucially, we are checking the fastreuseport field on the inet_bind_bucket, and
>> >> > > not the sk_reuseport variable on the other sockets in the bucket. Since this
>> >> > > bit is set based on sk_reuseport at the time the first socket binds (see
>> >> > > tb_not_found), I can see no reason why sockets need to keep SO_REUSEPORT set
>> >> > > beyond initial binding.
>> >> > >
>> >> > > Given this, I believe Willy's patch elegantly solves the problem at hand.
>> >> >
>> >> > Great, thanks for your in-depth explanation.
>> >> >
>> >> > Eric, do you think that this patch may be acceptable material for next
>> >> > merge window (given that it's not a fix per-se) ? If so I'll resubmit
>> >> > later.
>> >>
>> >> I need to check with Craig Gallek, because he was about to upstream a
>> >> change to make SO_REUSEPORT more scalable & sexy (like having an [e]BPF
>> >> filter to perform the selection in an array of sockets)
>> >

Hi All,

I apologize for not properly following up on this. I had the
impression that we did not want to merge my original patch and then I
also noticed that it fails to keep the hash consistent. Recently, I
read the follow ups on it as well as Willy's patch/proposals.

Is there any update on Willy's SO_REUSEPORT patch? IMHO, it solves the
problem and it is simpler than adding new sock option.

Best Regards,
Tolga Ceylan
