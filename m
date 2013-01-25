From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH net] net: usbnet: prevent buggy devices from killing us
Date: Fri, 25 Jan 2013 13:02:38 +0100
Message-ID: <1659086.jLlTU1VIap@linux-5eaq.site>
References: <2556579.vjYlY1iKn5@linux-5eaq.site> <1794053.fjSaMDVud2@linux-5eaq.site> <87ham5g2gk.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:43134 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783Ab3AYMCj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 07:02:39 -0500
In-Reply-To: <87ham5g2gk.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 25 January 2013 08:13:15 Bj=F8rn Mork wrote:
> Oliver Neukum <oliver@neukum.org> writes:
> > On Thursday 24 January 2013 20:16:56 Bj=F8rn Mork wrote:
> >> A device sending 0 length frames as fast as it can has been
> >> observed killing the host system due to the resulting memory
> >> pressure.
> >>=20
> >> Temporarily disable RX skb allocation and URB submission when
> >> the current error ratio is high, preventing us from trying to
> >> allocate an infinite number of skbs.  Reenable as soon as we
> >> are finished processing the done queue, allowing the device
> >> to continue working after short error bursts.
> >>=20
> >> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
> >> ---
> >> So is this starting to look OK?
> >
> > It seems to me that we at least need to try some error recovery.
>=20
> Won't the disabling code in usbnet_bh do? RX will only stay disabled
> until the done queue is handled.

So will the burst of bogus packets stop by itself?

>=20
> > How about resetting the device when it is no longer used?
>=20
> Yes, that we should do. I guess usbnet_open is the place to reset the
> flag and counters? I'll send another version taking care of this and
> Joes comment.

I was thinking about resetting the device, not just counters.
But yes, open() needs to reset the counters, too.

	Regards
		Oliver
