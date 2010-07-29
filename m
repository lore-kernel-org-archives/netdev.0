From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: can: expected receive behavior broken
Date: Thu, 29 Jul 2010 11:36:46 +0200
Message-ID: <4C514BAE.4070201@hartkopp.net>
References: <201007280956.38957.matthias.fuchs@esd.eu>
	<4C4FE7AC.4010806@grandegger.com>
	<201007281023.25039.matthias.fuchs@esd.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Matthias Fuchs <matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <201007281023.25039.matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
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

On 28.07.2010 10:23, Matthias Fuchs wrote:
> plx_pci/sja1000 + esd_usb2
> 

Hi Matthias,

i added a test program to the SVN that checks whether the CAN_RAW_LOOPBACK and
CAN_RAW_RECV_OWN_MSGS socket options work properly (in can.ko and can-raw-ko
and vcan.ko).

So far i was only able to test it on vcan0, as i'm on a business trip and
don't have a real CAN hardware with me.

I'll enhance it to force the CAN netdev to be given on the commandline.

Regarding your request, i was able to see the bad behaviour in the latest
net-next-2.6. You need to make

    modprobe vcan echo=1

before creating vcan devices to test the loopback on driver level!

Invoking tst-rcv-own-msgs produces this output, which is far away from the
correct (wanted) output seen in the commit message below.

sockopt default
 s : 0
 t : 0
 timeout
sockopt - -
 timeout
sockopt - R
 timeout
sockopt L -
 s : 3
 t : 3
 timeout
sockopt L R
 s : 4
 t : 4
 timeout
done.

I'll check that with the latest linux-2.6 (after rebooting :-)

Thanks for the hint! I'll run the tst-rcv-own-msgs test tool on the upcoming
net-next-2.6's and also put it into LTP later on.

Regards,
Oliver

--- snip! ---

Added:
   trunk/test/tst-rcv-own-msgs.c
Modified:
   trunk/test/Makefile
Log:
Added test programm to check the correct functionality of
CAN_RAW_LOOPBACK and CAN_RAW_RECV_OWN_MSGS socket options.

It needs a vcan0 virtual CAN network interface and should produce an output
like this, when invoked:

sockopt default
 t : 0
 timeout
sockopt - -
 timeout
sockopt - R
 timeout
sockopt L -
 t : 3
 timeout
sockopt L R
 s : 4
 t : 4
 timeout
done.


> 
> On Wednesday 28 July 2010 10:17, Wolfgang Grandegger wrote:
>> On 07/28/2010 09:56 AM, Matthias Fuchs wrote:
>>> Hi,
>>>
>>> I just noticed that the receive behavior of CAN sockets is broken
>>> in current net-next-2.6.
>>> I wrote some simple code that receives messages and echos them back to
>>> the bus. When I now trigger one single message on the bus, I get
>>> this message received and echoed back in an endless loop.
>>>
>>> I do not touch the sockopts CAN_RAW_LOOPBACK or CAN_RAW_RECV_OWN_MSGS in my code.
>>> Only (!) setting CAN_RAW_LOOPBACK to 0 helps at the moment. But this behavior
>>> actually has nothing to do with LOOPBACK but more with RECV_OWN_MSGS.
>>
>> Sounds wired! What driver are you using?
>>
>> Wolfgang.
>>
>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
