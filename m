From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v3 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Tue, 11 Jan 2011 09:29:50 +0100
Message-ID: <4D2C14FE.7080903@grandegger.com>
References: <1294135195-9448-1-git-send-email-bhupesh.sharma@st.com>
	<4D2829C5.5020206@grandegger.com>
	<D5ECB3C7A6F99444980976A8C6D896384DEAFA2D9D@EAPEX1MAIL1.st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
To: Bhupesh SHARMA <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <D5ECB3C7A6F99444980976A8C6D896384DEAFA2D9D-8vAmw3ZAcdzhJTuQ9jeba9BPR1lH4CV8@public.gmane.org>
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

Hi Bhupesh,

On 01/11/2011 05:50 AM, Bhupesh SHARMA wrote:
> Hi Wolfgang,
> 
> Thanks for your review.
> Please see my comments inline.
> 
>> -----Original Message-----
>> From: Wolfgang Grandegger [mailto:wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org]
...

>>> + * Bosch C_CAN controller is compliant to CAN protocol version 2.0
>> part A and B.
>>> + * Bosch C_CAN user manual can be obtained from:
>>> + * http://www.semiconductors.bosch.de/pdf/Users_Manual_C_CAN.pdf
>>
>> Unfortunately, this link is not valid any more.
> 
> Oops..
> It seems they have shifted to:
> http://www.semiconductors.bosch.de/media/en/pdf/ipmodules_1/c_can/users_manual_c_can.pdf

Ah, nice. I was not aware of that new link.

...
>>> +int c_can_write_msg_object(struct net_device *dev,
>>> +                   int iface, struct can_frame *frame, int objno)
>>> +{
>>> +   int i;
>>> +   u16 flags = 0;
>>> +   unsigned int id;
>>> +   struct c_can_priv *priv = netdev_priv(dev);
>>> +
>>> +   if (frame->can_id & CAN_EFF_FLAG) {
>>> +           id = frame->can_id & CAN_EFF_MASK;
>>> +           flags |= IF_ARB_MSGXTD;
>>> +   } else
>>> +           id = ((frame->can_id & CAN_SFF_MASK) << 18);

I just realize that the  {} for the else block is missing.

>>> +   /*
>>> +    * check for 'last error code' which tells us the
>>> +    * type of the last error to occur on the CAN bus
>>> +    */
>>> +   switch (lec_type) {
>>> +           /* common for all type of bus errors */
>>> +           priv->can.can_stats.bus_error++;
>>> +           stats->rx_errors++;
>>> +           cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
>>> +           cf->data[2] |= CAN_ERR_PROT_UNSPEC;
>>
>> Are you sure that this part is ever executed? I wonder why the compile
>> does
>> not complain.
> 
> I did not get any compilation error.

I know.

> But I will check if the program flow enters this part or not.

Good. It was *not* executed in my little user space test program.

...
>>> +static int __devexit c_can_plat_remove(struct platform_device *pdev)
>>> +{
>>> +   struct net_device *dev = platform_get_drvdata(pdev);
>>> +   struct c_can_priv *priv = netdev_priv(dev);
>>> +   struct resource *mem;
>>> +
>>> +   /* disable all interrupts */
>>> +   c_can_enable_all_interrupts(priv, DISABLE_ALL_INTERRUPTS);
>>
>> To avoid exportign that function, couldn't it be done at the beginning
>> of
>> unregister_c_can_dev()?
> 
> Yes this can be done.
> But, IMHO *disabling* interrupts seems more logical as part of __devexit
> Code.

I think the interrupts are already disabled when you unload the module
because the device must be closed (c_can_stop has been called). Anyway,
I think the above c_can_enable_all_interrupts() call is well placed in
the unregister function. I would avoid the export the function.

Wolfgang.
