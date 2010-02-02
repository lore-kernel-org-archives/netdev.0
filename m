From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH net-next-2.6 v2] can: mcp251x: Move to threaded interrupts
 instead of workqueues.
Date: Tue, 02 Feb 2010 11:00:19 +0100
Message-ID: <4B67F7B3.8060509@grandegger.com>
References: <cabda6421001310939g4acd22d2ua8dab4de3322f90e@mail.gmail.com> <1264959793-1797-1-git-send-email-chripell@fsfe.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: Christian Pellegrin <chripell@fsfe.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:36462 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755009Ab0BBKBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 05:01:33 -0500
In-Reply-To: <1264959793-1797-1-git-send-email-chripell@fsfe.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Christian,

the discussion about OSM brought up the issue with bus errors...

Christian Pellegrin wrote:
> This patch addresses concerns about efficiency of handling incoming
> packets. Handling of interrupts is done in a threaded interrupt handler
> which has a smaller latency than workqueues. This change needed a rework
> of the locking scheme that was much simplified. Some other (more or less
> longstanding) bugs are fixed: utilization of just half of the RX
> buffers, useless wait for interrupt on open, more reliable reset
> sequence. The MERR interrupt is not used anymore: it overloads the CPU
> in bus-off state without any additional information.

The MERR should not come when the device is in bus-off. Nevertheless, it
  may come frequently in any state below, e.g. error passive. We regard
bus-errors as vital information and they should be communicated to user
space via error messages. For exactly that reason we do not disable bus
errors on other CAN controllers, like the SJA1000 or the AT91, even if
they may produce high load. But we may discuss some generic interface to
disable bus-errors somehow, maybe configurable via ctrlmode. What do you
think?

Wolfgang.
