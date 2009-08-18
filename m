From: David Miller <davem@davemloft.net>
Subject: Re: new ipdelay= option for faster netboot
Date: Mon, 17 Aug 2009 22:00:08 -0700 (PDT)
Message-ID: <20090817.220008.26173943.davem@davemloft.net>
References: <4A8A02CA.7040305@am.sony.com>
	<20090817.182754.50348941.davem@davemloft.net>
	<200908180656.54011.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tim.bird@am.sony.com, r.schwebel@pengutronix.de,
	linux-kernel@vger.kernel.org, linux-embedded@vger.kernel.org,
	arjan@linux.intel.com, kernel@pengutronix.de,
	netdev@vger.kernel.org
To: vda.linux@googlemail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751485AbZHRE76@vger.kernel.org>
In-Reply-To: <200908180656.54011.vda.linux@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denys Vlasenko <vda.linux@googlemail.com>
Date: Tue, 18 Aug 2009 06:56:53 +0200

> Since DHCP and any other networking activity like TCP connects
> accomodate packet loss, things should work even without any delay
> in kernel IP config code. The delay will be just shifted to the
> moment when first DHCP/TCP/whatever negotiation happens.

Until the link is up, the packet scheduler just holds onto packets
and queued them up.

When the link comes up, this queue is released and the packets
sent out.

That's why it's beneficial to wait some time until the link
comes up before we start sending stuff out.  Because otherwise
any timeouts used will be inaccurate.

This could code be spiffed up to wait for the link up indication
on devices it cares about.  Feel free to code that up :-)
