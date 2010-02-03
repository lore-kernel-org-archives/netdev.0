From: christian pellegrin <chripell@fsfe.org>
Subject: Re: [PATCH net-next-2.6 v2] can: mcp251x: Move to threaded interrupts
	instead of workqueues.
Date: Wed, 3 Feb 2010 08:23:17 +0100
Message-ID: <cabda6421002022323m6ea676afu6c73843280b75e24@mail.gmail.com>
References: <cabda6421001310939g4acd22d2ua8dab4de3322f90e@mail.gmail.com>
	 <1264959793-1797-1-git-send-email-chripell@fsfe.org>
	 <4B67F7B3.8060509@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f215.google.com ([209.85.220.215]:55515 "EHLO
	mail-fx0-f215.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752862Ab0BCHXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 02:23:19 -0500
Received: by fxm7 with SMTP id 7so1136254fxm.28
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2010 23:23:17 -0800 (PST)
In-Reply-To: <4B67F7B3.8060509@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 2, 2010 at 11:00 AM, Wolfgang Grandegger <wg@grandegger.com> wrote:
> Hi Christian,
>

Hi,

>
> The MERR should not come when the device is in bus-off. Nevertheless, it

yes, sorry it's in error-passive state!

> space via error messages. For exactly that reason we do not disable bus
> errors on other CAN controllers, like the SJA1000 or the AT91, even if
> they may produce high load. But we may discuss some generic interface to
> disable bus-errors somehow, maybe configurable via ctrlmode. What do you
> think?

The transition of CAN error states is handled by the ERR interrupt,
the MERR means "message error" and is fired when a transmission or
receptions leads to an error. The problems with this interrupt are:

1) it's impossible to know if it was a TX or RX error.

2) if the error is accounted (for example) to TX the user will see
ton's of TX errors even if he sent just one packet (this happens in
error-passive mode for example) which could be confusing.

3) I guess that microchip has a specific use of this interrupt in mind
which explains it's drawbacks. From the data sheet:

"7.4        Message Error Interrupt
When an error occurs during transmission or reception
of a message the message error flag (CAN-
INTF.MERRF) will be set and, if the CANINTE.MERRE
bit is set, an interrupt will be generated on the INT pin.
This is intended to be used to facilitate baud rate deter-
mination when used in conjunction with listen-only
mode."

I think that a much more useful information to somehow export to the
user are the TEC and REC counters. I checked other CAN drivers but no
one seems to do this. Anyway let me know what do you think so I could
prepere the final patch now that OSM problems where sorted out.



-- 
Christian Pellegrin, see http://www.evolware.org/chri/
"Real Programmers don't play tennis, or any other sport which requires
you to change clothes. Mountain climbing is OK, and Real Programmers
wear their climbing boots to work in case a mountain should suddenly
spring up in the middle of the computer room."
