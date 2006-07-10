From: Stefan Rompf <stefan@loplof.de>
Subject: Re: [PATCH RFC]rfkill - Hardware button support for Wireless cards
Date: Tue, 11 Jul 2006 00:34:47 +0200
Message-ID: <200607110034.47944.stefan@loplof.de>
References: <a32f33a40607090849h737287a0k9f4d95669aa0ce9c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Jiri Benc" <jbenc@suse.cz>,
	"Francois Romieu" <romieu@fr.zoreil.com>,
	"Vojtech Pavlik" <vojtech@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from natlemon.rzone.de ([81.169.145.170]:22417 "EHLO
	natlemon.rzone.de") by vger.kernel.org with ESMTP id S965286AbWGJWcb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 18:32:31 -0400
To: "Ivo Van Doorn" <ivdoorn@gmail.com>
In-Reply-To: <a32f33a40607090849h737287a0k9f4d95669aa0ce9c@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Sonntag, 9. Juli 2006 17:49 schrieb Ivo Van Doorn:

> I have been quite busy lately, hence the reason for this late continuance
> of the Hardware button support for Wireless cards discussion.
> I have CC'ed the people who discussed this in earlier threads.

no problem. Look good, just one thing I'm missing:

> +	For each registered hardware button an input device will be created.
> +	If this input device has been opened by the user, rfkill will send a
> +	signal to userspace instead of the hardware about the new button
> +	status. This will allow userpace to perform the correct steps
> +	in order to bring down all interfaces.

> +		if (rfkill->input_dev->users) {
> +			input_report_key(rfkill->input_dev,
> +				KEY_RFKILL, new_status);
> +			input_sync(rfkill->input_dev);

Shouldn't there be a continue to avoid calling enable/disable_radio()?

> +		}

Stefan

PS: This rfkill stuff is really caught between two stools. Sending a netlink 
event for the device with an additional TLV for radio button status seems as 
valid as sending an input event...
