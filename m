From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] PS3: gelic: Add wireless support for PS3
Date: Sun, 16 Dec 2007 12:49:14 -0500
Message-ID: <1197827354.6358.2.camel@localhost.localdomain>
References: <20071213211626.BF8E.MOKUNO@sm.sony.co.jp>
	 <1197580418.14270.6.camel@localhost.localdomain>
	 <20071214134918.275E.MOKUNO@sm.sony.co.jp>
	 <1197637127.16724.1.camel@localhost.localdomain>
	 <20071215014244.GI5698@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Masakazu Mokuno <mokuno@sm.sony.co.jp>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	geoffrey.levand@am.sony.com,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
To: Jouni Malinen <j@w1.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39629 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752462AbXLPRuP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Dec 2007 12:50:15 -0500
In-Reply-To: <20071215014244.GI5698@jm.kir.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2007-12-14 at 17:42 -0800, Jouni Malinen wrote:
> On Fri, Dec 14, 2007 at 07:58:47AM -0500, Dan Williams wrote:
> > On Fri, 2007-12-14 at 14:03 +0900, Masakazu Mokuno wrote:
> > > The PS3 wireless device does the association and 4way handshake in its
> > > firmware/hypervisor.  No interventions between them are allowed to the guest
> > > OSes.  
> 
> > That sort of sucks; but I guess there's not too much you can do about
> > it.  That probably means that using wpa_supplicant + WPA is completely
> > out of the picture, which unfortunately makes the PS3 wireless unlike
> > any other card, which would require special-casing the PS3 in userspace
> > tools.
> 
> The current wpa_supplicant development branch (0.6.x) supports drivers
> that want to do 4-way handshake in the driver/firmware (e.g., OSX,
> iPhone, this PS3 driver). In case of WPA-PSK, this doesn't really mean
> more than just passing through the passphrase/PSK to the association
> routine, but still, this allows the driver to be configured through
> wpa_supplicant, if desired.
> 
> However, there is a part that you are not going to like.. This is likely
> using a private ioctl for some parts of the association requests, i.e.,
> no -Dwext.. I would assume that this could be cleaned up, though, if
> WEXT would be extended a bit to allow one more enc_capa to notify
> whether the driver wants to take care of 4-way handshake and to allow
> the PSK to be configured with a new key type.

Yeah, I was going to propose that on Friday but got side-tracked.  What
would require a new key type?  Are there some firmwares that _only_
accept the WPA passphrase?  Because if there aren't (PS3 accepts WPA hex
keys too) then the supplicant could just pass the hex key.  Not quite
sure what you mean here with "new key type".

Dan

> 
> PS.
> 
> It would be interesting to see whether the driver/firmware/hypervisor
> could be convinced to allow EAPOL frames to go through between
> association and 4-way handshake (which would be completed by
> driver/firmware). This is the way I can support WPA/WPA2-Enterprise with
> OSX..
> 

