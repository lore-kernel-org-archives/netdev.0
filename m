From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Wed, 25 Oct 2006 10:24:43 +0200
Message-ID: <20061025102443.3997dbad@griffin.suse.cz>
References: <43e72e890610231541k2e8e6dcbq98f58a77aa8a52d7@mail.gmail.com>
	<1161646361.3942.21.camel@johannes.berg>
	<43e72e890610232233t14ee98f6j5d5facf1b7aab08b@mail.gmail.com>
	<20061024120303.GB30724@tuxdriver.com>
	<43e72e890610241041l5d442753xd6cef0bca789db33@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"Johannes Berg" <johannes@sipsolutions.net>,
	netdev@vger.kernel.org, "Jean Tourrilhes" <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:38877 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1423117AbWJYIYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 04:24:45 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
In-Reply-To: <43e72e890610241041l5d442753xd6cef0bca789db33@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Oct 2006 13:41:12 -0400, Luis R. Rodriguez wrote:
> Sure -- we can have on the ieee80211_conf struct an array of all
> regulatory domains stack values that the device supports
> (REGDOMAIN_FCC or 0x10 for FCC for example) if the developer agrees
> the device has been certified to match the regulatory domain
> restrictions as the stack defines it. I believe most modern devices
> adhere to the PtMP restrictions pretty loosely and the magic is left
> to the driver when the device is being certified so ultimately I see
> devices sharing regulatory domains restrictions rather than defining
> their own though. I'd consider defining your own device-specific
> regulatory domain would be more of an exception we'd have to deal with
> but that remains to be seen yet huh.

It sounds overcomplicated to me. I'd rather like to see something like
this:
1. As part of the initialization of the hardware, the driver detects
   that the device is certified for (say) channels 2 to 10 (that's not
   a real-life example, fortunately :-)).
2. The driver reports this somewhere (softmac drivers would report this
   to the stack).
3. Based on outside conditions (userspace - or something - tells us
   about actual regdomain), the stack (or whatever) calls the driver and
   passes allowed channels etc. to it (if the driver wants that
   information). There is already previously reported driver's
   limitation taken in the account in that information.
4. If the outside conditions change (802.11d or user emigrates or
   something) that callback is called again with a new data.

I.e.:
- I see no point in building a list of regdomains suported by the
  hardware.
- It's pretty common that the device has some limitation stated in the
  EPROM and the stack/something should deal with it in a way that is easy
  to use in a driver.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
