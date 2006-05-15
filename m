From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: SIOCSIWESSID + SIOCSIWAP behaviour
Date: Mon, 15 May 2006 14:55:23 -0700
Message-ID: <20060515215523.GA7570@bougret.hpl.hp.com>
References: <4467BD47.5040000@gentoo.org> <1147663779.2204.27.camel@localhost.localdomain> <20060515202813.GA7400@bougret.hpl.hp.com> <20060515214014.GA12019@instant802.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, Daniel Drake <dsd@gentoo.org>,
	netdev@vger.kernel.org, softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from tayrelbas01.tay.hp.com ([161.114.80.244]:6587 "EHLO
	tayrelbas01.tay.hp.com") by vger.kernel.org with ESMTP
	id S964831AbWEOVzZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 17:55:25 -0400
To: Jouni Malinen <jkm@devicescape.com>
Content-Disposition: inline
In-Reply-To: <20060515214014.GA12019@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 15, 2006 at 02:40:14PM -0700, Jouni Malinen wrote:
> On Mon, May 15, 2006 at 01:28:13PM -0700, Jean Tourrilhes wrote:
> 
> > 	I believe the BSSID has to be unique. HP APs can also offer
> > multiple ESSID for the same BSSID, but they do so using different
> > BSSID. If you look at the 802.11 spec, I can't see how two different
> > virtual cells can have the same BSSID, because the BSSID is the only
> > thing that identify the cell (the ESSID is not in each packet).
> 
> What the standard says is somewhat irrelevant since there are APs that
> use multiple SSID with the same BSSID. I would say that it is reasonable
> for users to expect that this works with Linux, too.

	Yeah, I guess it's required when you are using standard client
card, but using the same BSSID is not as clean.

> > 	Personally, I think that SIWAP is too tricky to use properly
> > for most users, so we should encourage them to not use it.
> 
> Keep in mind that it is also used by some programs (e.g., wpa_supplicant
> in ap_scan=1) without the user having to know anything about that level
> of details..

	My point is that we don't have to be perfect with respect to
the end user through SIWAP.

> > 	There is still a performance issue. Having to cancel and
> > restart associations waste CPU cycles. One way to deal with that would
> > be to improve the "commit" strategy of the Wireless API. Basically,
> > every time you do a set, you schedule or reschedule the "commit" ioctl
> > to happen in a few dozen ms. This way, you could bundle all the
> > settting of apps such as wpa_supplicant with only a single
> > commit. This is similar to the way the routing API works.
> 
> Number of drivers use an atomic "associate" command (usually, a private
> ioctl) with wpa_supplicant. If there were a standard way of doing that,
> it could be helpful.

	My goal was to offer the "commit" mechanism to solve those
issues. The basic plumbing is in place, so we just a slightly more
clever "commit" mechanism. The advantage is that the mechanism is
generic, so will work for anything.

> Jouni Malinen                                            PGP id EFC895FA

	Jean
