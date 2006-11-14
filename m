From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: bcm43xx-d80211 broadcast reception with WPA
Date: Tue, 14 Nov 2006 15:40:24 +0100
Message-ID: <1163515224.2762.22.camel@ux156>
References: <ej09qf$2nv$1@sea.gmane.org> <200611111607.05420.mb@bu3sch.de>
	 <20061112012430.GA29648@keitarou> <200611120934.28133.mb@bu3sch.de>
	 <20061114142959.GA17486@keitarou>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:63183 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S965893AbWKNOjU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 09:39:20 -0500
To: Paul TBBle Hampson <Paul.Hampson@Pobox.com>
In-Reply-To: <20061114142959.GA17486@keitarou>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-11-15 at 01:29 +1100, Paul TBBle Hampson wrote:

> Just to summarise results so far:
> 
> (Current version)
> bcm43xx-d80211 w/v3 firmware and TKIP: Garbled broadcast RX
> bcm43xx-d80211 w/v4 firmware and TKIP: Garbled broadcast RX
> bcm43xx-d80211 w/v4 firmware and WEP-104: Correct broadcast RX
> 
> (version from wireless-dev before October 23rd, unsure of exact date)
> bcm43xx (softmac) w/v3 firmware and TKIP: Correct broadcast RX

The last item is interesting. The softmac version doesn't include any hw
crypto so it never checks the 'decrypt attempted' bit in the RX header
afaik, leaving all crypto to hw.

I postulated before that the problem is that the firmware sets the
'decrypt attempted' bit even if the key is none, hence the driver tells
the d80211 stack that the frame was already decrypted (no decrypt error
occurs because in reality the algorithm is 'none'.)

You could test this theory by clearing the 'decrypt attempted' bit
unconditionally in the RX path before it is ever tested. Then, any
wep/aes should no longer work properly with v4 firmware and
bcm43xx-d80211, but tkip would. If my theory is correct.

johannes
