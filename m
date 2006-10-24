From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Tue, 24 Oct 2006 13:41:12 -0400
Message-ID: <43e72e890610241041l5d442753xd6cef0bca789db33@mail.gmail.com>
References: <43e72e890610231541k2e8e6dcbq98f58a77aa8a52d7@mail.gmail.com>
	 <1161646361.3942.21.camel@johannes.berg>
	 <43e72e890610232233t14ee98f6j5d5facf1b7aab08b@mail.gmail.com>
	 <20061024120303.GB30724@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Johannes Berg" <johannes@sipsolutions.net>,
	netdev@vger.kernel.org, "Jiri Benc" <jbenc@suse.cz>,
	"Jean Tourrilhes" <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:15402 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1161112AbWJXRlS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 13:41:18 -0400
Received: by ug-out-1314.google.com with SMTP id 32so274059ugm
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2006 10:41:12 -0700 (PDT)
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061024120303.GB30724@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/24/06, John W. Linville <linville@tuxdriver.com> wrote:
> On Tue, Oct 24, 2006 at 01:33:32AM -0400, Luis R. Rodriguez wrote:
> > On 10/23/06, Johannes Berg <johannes@sipsolutions.net> wrote:
> > >On Mon, 2006-10-23 at 18:41 -0400, Luis R. Rodriguez wrote:
> > >
> > >> The current setup on d80211.h makes regulatory domains device
> > >> specific. I believe this should be changed to be stack-specific --
> > >> that is, all drivers adhere to the restrictions set by the stack's
> > >> current regulatory domain.
> > >
> > >There should be a way to have a certain device restrict that even
> > >further, if the driver wants to allow operation only in a domain that
> > >the device has been certified for (because it may malfunction otherwise,
> > >for example).
> >
> > Sure good idea -- we can provide a device specific regulatory domain
> > if necessary. We can easily introduce a device_regdomains linked list
> > on the ieee80211_conf which if not empty the driver will use it, else
> > the stack regdomain is used. The ieee80211_regdomains module already
> > provides the interfaces for the manipulation of such list. Pretty easy
> > fix, fortunately.
>
> It might be nice if this could be a "logical AND" operation?  So if the
> device was certified for X, Y, and Z and the current domain allows V,
> W, and X then only X would be allowed.  Perhaps it is too complicated
> to be worthwhile, but it seems doable and would be a nice flexibility.

Sure -- we can have on the ieee80211_conf struct an array of all
regulatory domains stack values that the device supports
(REGDOMAIN_FCC or 0x10 for FCC for example) if the developer agrees
the device has been certified to match the regulatory domain
restrictions as the stack defines it. I believe most modern devices
adhere to the PtMP restrictions pretty loosely and the magic is left
to the driver when the device is being certified so ultimately I see
devices sharing regulatory domains restrictions rather than defining
their own though. I'd consider defining your own device-specific
regulatory domain would be more of an exception we'd have to deal with
but that remains to be seen yet huh.

  Luis
