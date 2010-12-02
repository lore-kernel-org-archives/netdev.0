From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6] can: add slcan driver for serial/USB-serial
	CAN adapters
Date: Thu, 02 Dec 2010 21:57:37 +0100
Message-ID: <4CF80841.7010509@hartkopp.net>
References: <4CF40D75.8030203@hartkopp.net>
	<20101129233718.45dee61d@lxorguk.ukuu.org.uk>
	<4CF52911.6030900@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CF52911.6030900-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
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

As there's obviously no better idea, i would suggest to commit the slcan
driver in it's current shape as it has been used successfully (out of tree)
for more than two years now.

If there are new ideas to clean up the code of slip.c the slcan code can
follow these easily.

I'll send a v2 patch, as i accidentally missed the Makefile modification in
the first post.

Best regards,
Oliver


On 30.11.2010 17:40, Oliver Hartkopp wrote:
> On 30.11.2010 00:37, Alan Cox wrote:
>> On Mon, 29 Nov 2010 21:30:45 +0100
>> Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org> wrote:
>>
>>> This patch adds support for serial/USB-serial CAN adapters implementing the
>>> LAWICEL ASCII protocol for CAN frame transport over serial lines.
>>>
>>> The driver implements the SLCAN line discipline and is heavily based on the
>>> slip.c driver. Therefore the code style remains similar to slip.c to be able
>>> to apply changes of the SLIP driver to the SLCAN driver easily.
>>
>> It looks almost identical. Would it not be better to either extract the
>> common code or put slip and slcann together as one, otherwise changes
>> will always get missed as they have to be done twice ?
>>
>> How hard would it be to make the encap/decap pointers that can be
>> set to cleanly abstract both ?
> 
> My first approach was indeed to try to integrate the slcan ldisc into slip.
> But due to the higher complexity with dynamic memory for the buffers, the
> multiple #ifdef CONFIG_* blocks, the private statistics, the legacy ioctl()
> and compat stuff, MTU change, i decided to cut all the unneeded code and make
> an easy short driver from that ...
> 
> The things i did not really understand i preserved as-is 8-)
> Therefore the code looks that similar in some cases.
> 
> I wonder whether the code in
> 
> - sl_open()
> - sl_close()
> - slip_write_wakeup()
> - sl_xmit()
> - sl_free_netdev()
> - sl_sync()
> - sl_alloc()
> - slip_hangup()
> - slip_exit()
> 
> could be shared e.g. in some separate module where also
> drivers/net/hamradio/mkiss.c could participate?!?
> 
> This would need to unify the slip/slcan/mkiss structs.
> 
> Additionally mkiss.c does not have something like
> 
>     static struct net_device **slip_devs;
> 
> and creates the netdevices without parsing a fixed number of devices in
> mkiss_open(). But as i'm not a tty specialist i better kept my hands off these
> internals ...
> 
> Regards,
> Oliver
