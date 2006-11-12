From: Michael Buesch <mb@bu3sch.de>
Subject: Re: bcm43xx-d80211 broadcast reception with WPA
Date: Sun, 12 Nov 2006 09:34:27 +0100
Message-ID: <200611120934.28133.mb@bu3sch.de>
References: <ej09qf$2nv$1@sea.gmane.org> <200611111607.05420.mb@bu3sch.de> <20061112012430.GA29648@keitarou>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:6553
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1754098AbWKLIgJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Nov 2006 03:36:09 -0500
To: Paul TBBle Hampson <Paul.Hampson@pobox.com>
In-Reply-To: <20061112012430.GA29648@keitarou>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 12 November 2006 02:24, Paul TBBle Hampson wrote:
> On Sat, Nov 11, 2006 at 04:07:05PM +0100, Michael Buesch wrote:
> > Please _don't_ remove CCs.
> 
> Sorry, I was sending via the gmane web interface, I guess it doesn't
> honour CCs.
> 
> This one's via muttng's NNTP support to gmane, so I _think_ it's going
> to the right places.
> 
> > On Saturday 11 November 2006 07:32, Paul Hampson wrote:
> >> Michael Buesch <mb <at> bu3sch.de> writes:
> 
> > >> On Thursday 09 November 2006 23:23, Paul Hampson wrote:
> > > >> I've been backporting the bcm43xx-d80211 driver to whatever the released
> > > >> 2.6 kernel was using the rt2x00 project's d80211 stack (equivalent to
> > > >> current wireless-dev but with a workaround for not having a ieee80211_dev
> > > >> pointer and still using the _tfm interface instead of the _cypher interface.)
> 
> > > >> As of last night's wireless-dev tree bcm43xx, everything seems to be
> > > >> operating fine except incoming broadcast traffic is coming in 14 bytes too
> > > >> long and scrambled. I presume this means it's not decrypting properly...
> 
> > >> It sounds like a bug in the hardware decryption setup.
> > >> Are you using TKIP or not?
> 
> >> Yes, it's using TKIP. The router docs and the loading of the tkip module
> >> when I use the softmac driver agree on this.
> 
> > TKIP is still software encryption. Did you try with WPA-AES, for example,
> > which is hardware encryption?
> 
> The router here only supports TKIP that I can see. There's another
> network I'll be on on Monday night which I might be able to throw into
> WPA2 mode... In fact, I was there yesterday and couldn't even get a
> DHCP IP address, but didn't have the time to diagnose it.

TKIP hw encryption needs some modifications to the d80211 stack.
There are patches available, but I think they are not merged, yet.
John, do you know the state on these patches?

> > The problem might be that the card tries to decrypt mcast
> > frames in the crypto hardware, although we did not set a key.
> > So it uses a random key to decrypt. That obviously results in crap.
> 
> Eww, yuck.


Ah, and also note that you _need_ firmware from a v4 binary driver
to have hardware encryption with bcm43xx.

-- 
Greetings Michael.
