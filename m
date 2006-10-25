From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Wed, 25 Oct 2006 13:43:49 -0400
Message-ID: <43e72e890610251043y22fb9ce6ne5e036dd58f36505@mail.gmail.com>
References: <20061024140212.GB17543@devicescape.com>
	 <C86180A8C204554D8A3323D8F6B0A29F018523A5@dhost002-46.dex002.intermedia.net>
	 <43e72e890610241503r692975dfx65b2eab987ffbb3d@mail.gmail.com>
	 <200610241853.03135.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Simon Barber" <simon@devicescape.com>,
	"David Kimdon" <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, "Jiri Benc" <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jean Tourrilhes" <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:3772 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1161227AbWJYRnw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 13:43:52 -0400
Received: by ug-out-1314.google.com with SMTP id 32so163599ugm
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2006 10:43:50 -0700 (PDT)
To: "Michael Wu" <flamingice@sourmilk.net>
In-Reply-To: <200610241853.03135.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/24/06, Michael Wu <flamingice@sourmilk.net> wrote:
> On Tuesday 24 October 2006 18:03, Luis R. Rodriguez wrote:
> > 1. Anyone working on completing FullMAC support on d80211?
> That doesn't really make sense. Fullmac devices should just use WE or cfg80211
> because they, for the most part, do what d80211 does in firmware. There are
> also strange hybrid devices like ipw2100/ipw2200, but IMHO, it's not worth
> trying to bolt d80211 onto those devices unless saner firmware becomes
> available.

I guess my hope was that d80211 would just be more than a softmac
implementation. When I hear wireless stack I don't think "softmac
implementation", I think a robust set of headers and device
definitions which all wireless devices can share.

Also I thought we'd ditch WE as it seems we keep fixing it with gum
(as seen by Linville's latest ABI compatibility fix). If that wasn't
the case then I'm suggesting it -- can we consider ditching WE? I
appologize to get seriously off-topic here BTW but think I need to say
this. I mean -- we can keep on advancing WE but I really don't want to
deal with any more sub-ioctl hacks. I think its beeg good for us but I
think we're hitting the limit of its capabilities. Madwifi is an
example of a driver which has been breeded to live in the extremes of
WE -- you can't pack any more brand new ioctls there. Sub-ioctls were
just that -- a hack. Let's stop this and look for a better solution.
How about jumping on Johannes Berg's nl80211/cfg80211 and providing a
new user API through that?

> > 2. Who's working on a userspace MLME replacement for d80211 and where
> > are we with that?
> I think HostAP can handle authentication/association.. or was it
> wpa-supplicant? Maybe both..

As confirmed by Simon, wpa_supplicant. OK great.

> > 3. Who's doing the endianness/smp testing of d80211 and how far are we
> > with that?
> The endianness issues seemed fine the last time I checked, and people do seem
> to be testing BE enough that to uncover an endianness regression I introduced
> when converting WEP code to use crypto api. As for SMP/locking, I think Jiri
> Benc knows how to deal with this.

Jiri --- how is that coming along? :)

> >
> > Lastly, as I have said in previous e-mails -- I agree with a userspace
> > daemon but where is it and how long before its ready.. also it may be
> > difficult to introduce as a requirement for distributions and for this
> > reason I am suggesting going with in-kernel regulatory domain control
> > and now perhaps in-kernel MLME for a first stable push of d80211,
> > specially since only... 3 in-kernel drivers currently use d80211!
> >
> 4 once p54 is merged, and more to come as I get to them.
>
> /me pokes Linville.

and zd1211rw too, now that I'm done with sending RFC for regdomains
work. If I don't have time I'll pass what I have to you.

> I think time working on the in-kernel MLME is well worth it since I would like
> softmac drivers to have feature parity with fullmac drivers. Anything beyond
> that can go to userspace as far as I'm concerned. (so transitioning to d80211
> based drivers won't involve too much pain unless you really want to take
> advantage of new features)

Not having in-kernel MLME does not necessarily mean having a disparity
between SoftMAC and FullMAC. To me its more of a speed issue and a
requirement of having a userspace daemons before using a SoftMAC
wireless device. I can see distributions having issues with the
requirement of a new userspace daemon in order to use wireless SoftMAC
devices and would argue that if we can complete the in-kernel MLME
that perhaps we should do this for the introduction of d80211 to
stable and later on move it to userspace. I'd say lets just go for a
userspace MLME as its already written but I seriously think we need to
ditch replace WE first.

> Having some basic regulatory domain control in d80211 in the kernel should be
> okay for now just to make sure all drivers like the api presented. Working
> out the details of how to move the d80211 side stuff to userspace should be
> orthogonal to the driver interface and can be dealt with later, IMHO.

That is only true if we stick with WE.

  Luis
