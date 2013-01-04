From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2] usbnet: allow status interrupt URB to always be active
Date: Fri, 04 Jan 2013 23:16:31 +0100
Message-ID: <2212516.GkG3xP33yG@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <1357318096.5370.15.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Elina Pasheva <epasheva@sierrawireless.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:42542 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755117Ab3ADWQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 17:16:29 -0500
In-Reply-To: <1357318096.5370.15.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 04 January 2013 10:48:16 Dan Williams wrote:
> Some drivers (ex sierra_net) need the status interrupt URB
> active even when the device is closed, because they receive
> custom indications from firmware.  Allow sub-drivers to set
> a flag that submits the status interrupt URB on probe and
> keeps the URB alive over device open/close.  The URB is still
> killed/re-submitted for suspend/resume, as before.
> 
> Signed-off-by: Dan Williams <dcbw@redhat.com>
> ---
> Oliver: alternatively, is there a problem with *always*
> submitting the interrupt URB, and then simply not calling
> the subdriver's .status function when the netdev is
> closed?  That would be a much simpler patch.

That is quite radical. We have no idea what a device
does when we do not react to a status update. I would
much prefer to not take the risk.
Besides, we don't use bandwidth if we don't have to.

	Regards
		Oliver
