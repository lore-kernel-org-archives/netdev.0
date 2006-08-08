From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: 802.11/crypto questions
Date: Tue, 8 Aug 2006 08:57:26 -0700
Message-ID: <20060808155726.GA25393@instant802.com>
References: <1154410852.17333.4.camel@johannes.berg> <20060807172946.GI4702@instant802.com> <44D876FA.5080605@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-49.dex002.intermedia.net ([64.78.21.145]:16359 "EHLO
	dhost002-49.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1030183AbWHHQBd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 12:01:33 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <44D876FA.5080605@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 01:35:22PM +0200, Johannes Berg wrote:
> Jouni Malinen wrote:
> >Depends on what exactly you mean with "on the fly". We have indeed
> >changed between doing software and hardware crypto for some cases, e.g.,
> >when enabling another BSS while one BSS is using static WEP (which would
> >need default WEP keys in hwaccel) in one BSS, we may disable hwaccel for
> >the receive case. 

> Also, if we add a monitor if, does it disable hw crypto so we can see 
> the undecrypted frames?

I haven't looked at the current implementation (if this has been
modified), but it would be nice to have an option for doing this. This
gets a bit complex, but if having such an option is not going to slow
down the normal case (i.e., monitor mode disabled), being able to select
whether frames are decrypted in monitor interface could be useful. This
would, of course, require that hwaccel is disabled for normal data
packets when this kind of mode is enabled.

Because of quite large CPU load difference, I would expect there to be
valid use cases for both allowing hardware to continue decrypting frames
(and monitor interface would show whatever was received from hardware,
i.e., some frames may be decrypted, some not based on whether a key was
configured) and stopping hardware acceleration and delivering unmodified
frames into the monitor interface (and if a normal data connection is
active at the same time, doing software decryption for frames before
they are delivered to data interface).

-- 
Jouni Malinen                                            PGP id EFC895FA
