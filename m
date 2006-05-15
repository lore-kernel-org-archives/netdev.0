From: Jouni Malinen <jkm@devicescape.com>
Subject: Re: SIOCSIWESSID + SIOCSIWAP behaviour
Date: Mon, 15 May 2006 06:16:56 -0700
Message-ID: <20060515131656.GC9673@instant802.com>
References: <4467BD47.5040000@gentoo.org> <1147663779.2204.27.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd@gentoo.org>, Jean Tourrilhes <jt@hpl.hp.com>,
	netdev@vger.kernel.org, softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nexaweb.com ([64.78.21.133]:7551 "EHLO mail.nexaweb.com")
	by vger.kernel.org with ESMTP id S964776AbWEONUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 09:20:25 -0400
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1147663779.2204.27.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 14, 2006 at 11:29:38PM -0400, Dan Williams wrote:
> On Mon, 2006-05-15 at 00:29 +0100, Daniel Drake wrote:
> > When SIWESSID happens, softmac drops association/authentication with the 
> > current network and then starts a scan for the requested SSID. When 
> > found, softmac authenticates and associates to that network.

I don't think there is requirement for doing a new scan here if recent
scan results are available.

> > When SIWAP happens, softmac drops association/authentication with the 
> > current network and then starts a scan for the requested BSSID. When 
> > found, softmac authenticates and associates to that network.

Same here. Neither of these commands should drop IEEE 802.11
authentication. I would say that neither should drop association either
until a new association is available or it is clear that current
configuration does not allow association to be created. First case would
just report a new association (no disassociation reported) and second
case would report disassociation to user space.

> > Right now, wpa_supplicant does SIWESSID and SIWAP in quick succession, 
> > which causes softmac to associate twice, and that quickly confuses things.
> 
> (I don't really understand why wpa_supplicant uses SIWAP when a BSSID
> isn't specified in the config file, but...)

There are two different modes and what is being described here is
ap_scan=1, i.e., wpa_supplicant being responsible for requesting
scanning and selecting an AP. In this mode, it is actually assumed that
the driver does not do extra scans with SIWAP or SIWESSID.
wpa_supplicant is telling the driver which channel (SIOCSIWFREQ), SSID,
and BSSID to use.

In the other mode, ap_scan=2, wpa_supplicant is only configuring the
SSID and requesting the driver (or well, kernel side 802.11 management
code) to figure out which AP to use.

-- 
Jouni Malinen                                            PGP id EFC895FA
