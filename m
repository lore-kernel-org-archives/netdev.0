From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Wed, 15 Sep 2010 11:42:48 +0200
Message-ID: <4C909518.5010309@hartkopp.net>
References: <4C61EDE5.4030505@dsn.okisemi.com>	<4C629FE5.6000204@pengutronix.de>	<005f01cb533e$5c21d530$66f8800a@maildom.okisemi.com>	<4C8E1918.5000007@pengutronix.de>	<003a01cb53a6$4ca724d0$66f8800a@maildom.okisemi.com>
	<4C9078D3.50300@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Morinaga <morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>, meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org,
	arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4C9078D3.50300-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

On 15.09.2010 09:42, Wolfgang Grandegger wrote:
> On 09/14/2010 02:46 AM, Masayuki Ohtake wrote:
>> Hi Marc,
>>
>>>>> - implement NAPI
>>>> Since Topcliff CAN HW register has only single rx buffer,
>>>> I think NAPI is unnecessary.
>>
>>> Doesn't matter. Please try to implement it.
>>
>> Our CAN driver must pull received data from CAN-HW rx buffer as fast as it can
>> so that the received data is not over-written by next received data.
>> In case of implemented with NAPI,
>> since NAPI has time-lagging after receiving first packet,
>> probability of over-written(discarded) buffer is to be high.
>> Thus, for our CAN HW, we should NOT implement with NAPI but normal "netif_rx".
> 
> True, if you just use one RX-Object. But it just helps a little bit and
> it would be much better to use the buffering on RX messages in the CAN
> controller hardware, either by using more than one RX object, or
> combining RX objects to a FIFO, or whatever your CAN controller supports.

Good point!

As long as the order of the received CAN frames is not shuffled (-> plain FIFO
behaviour) using more than one RX buffer is a good idea.

Just a remark:

During the IDF the informations about the Topcliff Controller Hub have been
reworked, so that some of the documentation became available for the public:

http://edc.intel.com/Platforms/Atom-E6xx/#hardware

Especially the Datasheet for the Platform Controller Hub EG20T can be found:

http://download.intel.com/embedded/chipsets/datasheet/324211.pdf

In chapter 13 there are some details about the CAN controller.

Regards,
Oliver
