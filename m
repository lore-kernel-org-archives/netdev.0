From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH] Fix SJA1000 command register writes on SMP systems
Date: Mon, 17 May 2010 22:04:53 +0200
Message-ID: <4BF1A165.1040704@grandegger.com>
References: <4BF12321.6080506@hartkopp.net> <4BF152E4.1060306@grandegger.com>
	<4BF19D5B.1070604@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4BF19D5B.1070604-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/17/2010 09:47 PM, Oliver Hartkopp wrote:
> On 17.05.2010 16:29, Wolfgang Grandegger wrote:
>> Hi Oliver,
>>
>> On 05/17/2010 01:06 PM, Oliver Hartkopp wrote:
>>> The SJA1000 command register is concurrently written in the rx-path to free
>>> the receive buffer _and_ in the tx-path to start the transmission.
>>> On SMP systems this leads to a write stall in the tx-path, which can be
>>> solved by adding some locking for the command register in the SMP case.
>>
>> We should explain why a write stall can happen. Here is the relavant
>> part from the SJA1000 data sheet, 6.4.4 COMMAND REGISTER (CMR):
>>
>> "Between two commands at least one internal clock cycle is needed in
>> order to proceed. The internal clock is half of the external oscillator
>> frequency."
> 
> The delay directly after the register access can only be guaranteed when there
> is some locking around the command register write access.

Of course.

> In the end it boils down to a SMP issue again as this is (from all known
> environments) the only case, where the problem appears in reality.
> This was also what i've taken from the discussion on the SocketCAN ML.

I know.

> I don't stick on the patch description. Would you like to produce a different
> one? My Acked-by for the code remains sure :-)

I just suggested to mention the hardware requirements in the patch
description so people can understand why we need it. Feel free to add
what I wrote above.

Wolfgang.
