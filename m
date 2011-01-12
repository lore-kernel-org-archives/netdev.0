From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v4 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Wed, 12 Jan 2011 10:08:37 +0100
Message-ID: <4D2D6F95.8030502@grandegger.com>
References: <1294746592-12144-1-git-send-email-bhupesh.sharma@st.com>	<4D2C4D68.3070705@pengutronix.de>
	<D5ECB3C7A6F99444980976A8C6D896384DEAFA31B6@EAPEX1MAIL1.st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Bhupesh SHARMA <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <D5ECB3C7A6F99444980976A8C6D896384DEAFA31B6-8vAmw3ZAcdzhJTuQ9jeba9BPR1lH4CV8@public.gmane.org>
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

On 01/12/2011 09:51 AM, Bhupesh SHARMA wrote:
> Hi Marc,
> 
> Thanks for your review.
> Please see my comments inline:
> 
>> -----Original Message-----
>> From: Marc Kleine-Budde [mailto:mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org]
>> On 01/11/2011 12:49 PM, Bhupesh Sharma wrote:
...
>>> +static int c_can_close(struct net_device *dev) {
>>> +   struct c_can_priv *priv = netdev_priv(dev);
>>> +
>>> +   netif_stop_queue(dev);
>>> +   napi_disable(&priv->napi);
>>> +   c_can_stop(dev);
>>> +   free_irq(dev->irq, dev);
>>> +   close_candev(dev);
>>> +
>>> +   return 0;
>>> +}
>>> +
>>> +struct net_device *alloc_c_can_dev(void)
>>
>> Please model after alloc_sja1000_dev:
>>
>> struct net_device *alloc_sja1000dev(int sizeof_priv)
>>
>> The private for the _user_ of alloc_c_can_dev is behind the sja1000
>> private, so you can get rid of the void *priv member in the struct
>> c_can_priv. (see below)
> 
> Ok.
> But Wolfgang also suggested to use the *priv* member inside c_can_priv struct
> for board specific details. In my c_can platform driver I use it to
> store the *clk* variable. Do I need to change that as well?

Marc is referring to:

http://lxr.linux.no/#linux+v2.6.37/drivers/net/can/sja1000/sja1000.c#L582

But also there "priv->priv" is used to store a pointer to the board
specific details. Looking to the SJA1000 drivers, only *one* uses
"sizeof_priv > 0", but many other attach a separately allocated
structure to "priv->priv". For that reason, I'm fine with your current
implementation.

Wolfgang.
