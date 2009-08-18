From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: new ipdelay= option for faster netboot
Date: Tue, 18 Aug 2009 06:56:53 +0200
Message-ID: <200908180656.54011.vda.linux@googlemail.com>
References: <4A89DB15.6060101@am.sony.com> <4A8A02CA.7040305@am.sony.com> <20090817.182754.50348941.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: tim.bird@am.sony.com, r.schwebel@pengutronix.de,
	linux-kernel@vger.kernel.org, linux-embedded@vger.kernel.org,
	arjan@linux.intel.com, kernel@pengutronix.de,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <20090817.182754.50348941.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 18 August 2009 03:27, David Miller wrote:
> From: Tim Bird <tim.bird@am.sony.com>
> Date: Mon, 17 Aug 2009 18:24:26 -0700
> 
> > David Miller wrote:
> >> I have card/switch combinations that take up to 10 seconds to
> >> negotiate a proper link.
> > 
> > What types of delays are these timeouts supposed to
> > cover?
> 
> The problem is that if you don't first give at least some time for the
> link to come up, the remaining time it takes the link to come up will
> end up chewing into the actual bootp/dhcp protocol timeouts.  And
> that's what we're trying to avoid.

But in this case, they assign a static IP. They do not use DHCP.
So they pay this time penalty even if they wouldn't use networking
until sometime later (or never).

Since DHCP and any other networking activity like TCP connects
accomodate packet loss, things should work even without any delay
in kernel IP config code. The delay will be just shifted to the
moment when first DHCP/TCP/whatever negotiation happens.

If dropping delays altogether sounds too big a change,
then it makes sense at least to allow people to tweak it with
ipdelay=TIME_IN_MS

-- 
vda
