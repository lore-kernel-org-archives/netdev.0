From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] can: kvaser_usb: Add support for Kvaser CAN/USB devices
Date: Tue, 31 Jul 2012 15:43:05 +0200
Message-ID: <5017E0E9.7090202@grandegger.com>
References: <1343626352-24760-1-git-send-email-olivier@sobrie.be> <50166BF2.9000700@pengutronix.de> <20120730133323.GA13941@hposo> <5017ABC6.7030307@pengutronix.de> <20120731130650.GA23541@hposo>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Olivier Sobrie <olivier@sobrie.be>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20120731130650.GA23541@hposo>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/31/2012 03:06 PM, Olivier Sobrie wrote:
> On Tue, Jul 31, 2012 at 11:56:22AM +0200, Marc Kleine-Budde wrote:
...
>> Please test Bus-Off behaviour:
>> - setup working CAN network
>> - short circuit CAN-H and CAN-L wires
>> - start "candump any,0:0,#FFFFFFFF" on one shell
>> - send one can frame on the other
>>
>> then
>>
>> - remove the short circuit
>> - see if the can frame is transmitted to the other side
>> - it should show up as an echo'ed CAN frame on the sender side
>>
>> Repeat the same test with disconnecting CAN-H and CAN-L from the other
>> CAN station instead of short circuit.
>>
>> Please send the output from candump.
> 
> 1) With the short circuit:
> 
> I perform the test you described. It showed that the Kvaser passes from
> ERROR-WARNING to ERROR-PASSIVE and then BUS-OFF. But after going to the
> state BUS-OFF it comes back to ERROR-WARNING.

You can use the option "-e" to get a human readable output.

>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME

A state change (0x10 here) should only be reported once.

>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   ...
>   can1  200000C8  [8] 00 00 90 00 00 00 00 00   ERRORFRAME  <-- bus off
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   ...
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  123  [2] 11 22	          <-- short circuit removed
> 
> I see the echo and on the other end I see the frame coming in.
> By the way I see that the txerr and rxerr fields of the structure
> kvaser_msg_error_event stay at 0.

If possible, they should be set for any CAN error message.

> 
> 2) With CAN-H and CAN-L disconnected:
> 
> I never see the bus going in OFF state. It stays in PASSIVE mode.

That is the correct behavior. You should get ACK slot (and not ACK
delimiter), IIRC.

I'm offline for the rest of the week. I will have a closer look next
week (to your next version(s)).

Wolfgang.

