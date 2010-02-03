From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: mcp251x: Move to threaded interrupts
	instead of workqueues.
Date: Wed, 03 Feb 2010 08:49:33 +0100
Message-ID: <4B692A8D.2040000@grandegger.com>
References: <cabda6421001310939g4acd22d2ua8dab4de3322f90e@mail.gmail.com>	
	<1264959793-1797-1-git-send-email-chripell@fsfe.org>	
	<4B67F7B3.8060509@grandegger.com>
	<cabda6421002022323m6ea676afu6c73843280b75e24@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: christian pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <cabda6421002022323m6ea676afu6c73843280b75e24-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

christian pellegrin wrote:
> On Tue, Feb 2, 2010 at 11:00 AM, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org> wrote:
>> Hi Christian,
>>
> 
> Hi,
> 
>> The MERR should not come when the device is in bus-off. Nevertheless, it
> 
> yes, sorry it's in error-passive state!

Yep. That's where it sits if you send a message with no cable connected
or no other node on the bus.

>> space via error messages. For exactly that reason we do not disable bus
>> errors on other CAN controllers, like the SJA1000 or the AT91, even if
>> they may produce high load. But we may discuss some generic interface to
>> disable bus-errors somehow, maybe configurable via ctrlmode. What do you
>> think?
> 
> The transition of CAN error states is handled by the ERR interrupt,
> the MERR means "message error" and is fired when a transmission or
> receptions leads to an error. The problems with this interrupt are:
> 
> 1) it's impossible to know if it was a TX or RX error.
> 
> 2) if the error is accounted (for example) to TX the user will see
> ton's of TX errors even if he sent just one packet (this happens in
> error-passive mode for example) which could be confusing.

It's the same on the SJA1000, our reference controller.

> 3) I guess that microchip has a specific use of this interrupt in mind
> which explains it's drawbacks. From the data sheet:
> 
> "7.4        Message Error Interrupt
> When an error occurs during transmission or reception
> of a message the message error flag (CAN-
> INTF.MERRF) will be set and, if the CANINTE.MERRE
> bit is set, an interrupt will be generated on the INT pin.
> This is intended to be used to facilitate baud rate deter-
> mination when used in conjunction with listen-only
> mode."

OK. If the bus-error does not provide additional information, like ack,
form, stuff, bit, etc. error, it's maybe not worth to support it.
Therefore, not enabling MERR is fine for the moment.

> I think that a much more useful information to somehow export to the
> user are the TEC and REC counters. I checked other CAN drivers but no
> one seems to do this. Anyway let me know what do you think so I could
> prepere the final patch now that OSM problems where sorted out.

CAN experts told me/us, that the bus-errors might be important
information for an apps. I just started a thread on how to improve our
current bus-error handling implementation.

Wolfgang.
