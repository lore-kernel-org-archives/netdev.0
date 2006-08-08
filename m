From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: 802.11/crypto questions
Date: Tue, 8 Aug 2006 18:09:36 +0200
Message-ID: <200608081809.36823.IvDoorn@gmail.com>
References: <1154410852.17333.4.camel@johannes.berg> <44D876FA.5080605@sipsolutions.net> <20060808155726.GA25393@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:39397 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932214AbWHHQKH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 12:10:07 -0400
Received: by nf-out-0910.google.com with SMTP id q29so217001nfc
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2006 09:10:05 -0700 (PDT)
To: "Jouni Malinen" <jkm@devicescape.com>
In-Reply-To: <20060808155726.GA25393@instant802.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 08 August 2006 17:57, Jouni Malinen wrote:
> On Tue, Aug 08, 2006 at 01:35:22PM +0200, Johannes Berg wrote:
> > Jouni Malinen wrote:
> > >Depends on what exactly you mean with "on the fly". We have indeed
> > >changed between doing software and hardware crypto for some cases, e.g.,
> > >when enabling another BSS while one BSS is using static WEP (which would
> > >need default WEP keys in hwaccel) in one BSS, we may disable hwaccel for
> > >the receive case. 
> 
> > Also, if we add a monitor if, does it disable hw crypto so we can see 
> > the undecrypted frames?
> 
> I haven't looked at the current implementation (if this has been
> modified), but it would be nice to have an option for doing this. This
> gets a bit complex, but if having such an option is not going to slow
> down the normal case (i.e., monitor mode disabled), being able to select
> whether frames are decrypted in monitor interface could be useful. This
> would, of course, require that hwaccel is disabled for normal data
> packets when this kind of mode is enabled.
> 
> Because of quite large CPU load difference, I would expect there to be
> valid use cases for both allowing hardware to continue decrypting frames
> (and monitor interface would show whatever was received from hardware,
> i.e., some frames may be decrypted, some not based on whether a key was
> configured) and stopping hardware acceleration and delivering unmodified
> frames into the monitor interface (and if a normal data connection is
> active at the same time, doing software decryption for frames before
> they are delivered to data interface).

Would also depend on the hardware itself I would think.
Looking at the Legacy drivers from Ralink code for hardware encryption
it would be quite possible for having hardware decryption enabled
while also working in monitor mode. This is because the driver
will first receive the encrypted frame (at this time the driver could pass
it to the monitor interface) and then  signals the hardware encryption
machine to encrypt the frame after which the unencrypted frame can go through
the normal RX handling routines.
Only downside here, is that the receiving in this case should be specifically be done
to the monitor interface otherwise all frames would be send to the ieee80211 rx handler twice.

Note however that this is currently not possible with rt2x00 since that
has not yet implemented hardware encryption.

Ivo
