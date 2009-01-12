From: Oliver Neukum <oliver@neukum.org>
Subject: Re: another race in hso
Date: Mon, 12 Jan 2009 12:33:44 +0100
Message-ID: <200901121233.47050.oliver@neukum.org>
References: <200812221454.57794.oliver@neukum.org> <496B0605.70704@option.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <csnook@redhat.com>, schwidefsky@de.ibm.com,
	strasse@de.ibm.com, Paul Hardwick <P.Hardwick@option.com>,
	ajb@spheresystems.co.uk, "Greg Kroah-Hartman" <greg@kroah.com>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Denis Joseph Barrow <D.Barow@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:51791 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbZALLeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 06:34:00 -0500
In-Reply-To: <496B0605.70704@option.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Monday 12 January 2009 09:57:41 schrieb Denis Joseph Barrow:
> Oliver if you haven't given a detailed description of the patch you need to do so before the patch can be accepted
> especially a patch of this size.

The original driver has a race that left a window between submitting
a network packet and incrementing the usage counters preventing
autosuspension. In that window hard_start_xmit() races with suspend()
called for autosuspension.

The problem arises from having to increase the usage counters from
a context that cannot be slept in. A driver has to be able to deal with
suspend being called in that case and needing to return -EBUSY
or to delay transmission of the packet until resume() is called.
This needs to called with approriate (spin)locking.

This patch implements such handling in suspend() and unifies the spinlocks
from the network and the serial parts of the driver. Thus all code taking
a spinlock had to be touched.

	Regards
		Oliver

