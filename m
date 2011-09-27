From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH net-next v2] candev: allow SJW user setting for bittiming
	calculation
Date: Tue, 27 Sep 2011 19:32:37 +0200
Message-ID: <4E8208B5.4050907@hartkopp.net>
References: <4E7B0DE6.9020807@hartkopp.net>
	<4E7B8F63.6060108@hartkopp.net>	<4E7C3424.8030406@grandegger.com>
	<201109231132.49976.pisa@cmp.felk.cvut.cz>
	<4E7D8537.8010302@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4E7D8537.8010302-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

On 09/24/11 09:22, Wolfgang Grandegger wrote:

> On 09/23/2011 11:32 AM, Pavel Pisa wrote:

>> On base of above analysis, I think that blindly set SJW
>> on maximum is not good idea. It should be at least limited
>> to 5% of bit time. 


(..)


>> SJW is more problematic, but may it be use of 2 or 5%
>> of bittime by default with assurance that zero is
>> replaced by one, would serve to most people pleasure.


(..)

>> But there is still unknown parameter
>> capacity/length of connected wires so there is still
>> something left to user consideration.
> 
> Thanks for your detailed explanation. It clearly shows that adjusting
> SJW is non-trivial and nothing a normal CAN user should deal with. When
> adjusting SJW, do you also need to tweek other bit-timing parameters,
> e.g. tq? I mean, would "ip link set can0 type can bitrate x
> sampling-point y sjw z" work for your setup or do you need to use the
> expert mode setting via "ip link set can0 type can tq ..." anyway?


Hello Wolfgang,

i double checked a specification where i got my requirement to influence the
SJW value from. It says (non literally):

    "Put the SJW to the highest possible value only reduced by tseg2."

The fact that this requirement might no fit to any CAN setup or may not be  in
best academical shape is not my problem. My requirement is to provide an easy
way to move the SJW away from it's default value, which is currently
hard-coded to 1 in the can-dev framework when using it's bittiming calculation
function.

As almost everything is already done (only the provided SJW is not evaluated
in dev.c) this patch is IMO an valid option to support it. If Joe user can
tune the sampling point, why should he not be able to influence the SJW if he
thinks, he knows what he's doing?

Especially as the good working bittiming calculation is not touched in any way
and the default SJW remains 1 (even if '0' is provided as user input).

Regards,
Oliver
