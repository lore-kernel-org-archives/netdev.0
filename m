From: Michael Buesch <mb@bu3sch.de>
Subject: Re: bcm43xx-d80211 broadcast reception with WPA
Date: Sat, 11 Nov 2006 16:07:05 +0100
Message-ID: <200611111607.05420.mb@bu3sch.de>
References: <ej09qf$2nv$1@sea.gmane.org> <200611102112.33050.mb@bu3sch.de> <loom.20061111T070237-788@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:23486
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S965695AbWKKPIu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Nov 2006 10:08:50 -0500
To: Paul Hampson <Paul.Hampson@pobox.com>
In-Reply-To: <loom.20061111T070237-788@post.gmane.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please _don't_ remove CCs.

On Saturday 11 November 2006 07:32, Paul Hampson wrote:
> Michael Buesch <mb <at> bu3sch.de> writes:
> 
> > On Thursday 09 November 2006 23:23, Paul Hampson wrote:
> > > I've been backporting the bcm43xx-d80211 driver to whatever the released
> > > 2.6 kernel was using the rt2x00 project's d80211 stack (equivalent to
> > > current wireless-dev but with a workaround for not having a ieee80211_dev
> > > pointer and still using the _tfm interface instead of the _cypher interface.)
> 
> > > As of last night's wireless-dev tree bcm43xx, everything seems to be
> > > operating fine except incoming broadcast traffic is coming in 14 bytes too
> > > long and scrambled. I presume this means it's not decrypting properly...
> 
> > It sounds like a bug in the hardware decryption setup.
> > Are you using TKIP or not?
> 
> Yes, it's using TKIP. The router docs and the loading of the tkip module
> when I use the softmac driver agree on this.

TKIP is still software encryption. Did you try with WPA-AES, for example,
which is hardware encryption?

The problem might be that the card tries to decrypt mcast
frames in the crypto hardware, although we did not set a key.
So it uses a random key to decrypt. That obviously results in crap.

-- 
Greetings Michael.
