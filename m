From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH v2] can: Add driver for esd CAN-USB/2 device
Date: Mon, 10 May 2010 16:59:01 +0200
Message-ID: <4BE81F35.60607@grandegger.com>
References: <201005101528.50834.matthias.fuchs@esd.eu>
	<4BE80D6E.3040205@grandegger.com>
	<201005101640.39048.matthias.fuchs@esd.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Matthias Fuchs <matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <201005101640.39048.matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
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

On 05/10/2010 04:40 PM, Matthias Fuchs wrote:
> Hi Wolfgang,
> 
> On Monday 10 May 2010 15:43, Wolfgang Grandegger wrote:
>> Hi Matthias,
>>
>> On 05/10/2010 03:28 PM, Matthias Fuchs wrote:
>>> This patch adds a driver for esd's USB high speed
>>> CAN interface. The driver supports devices with
>>> multiple CAN interfaces.
>>>
>>> Signed-off-by: Matthias Fuchs <matthias.fuchs-iOnpLzIbIdM@public.gmane.org>
>>> ---
>>>
>>> version 2: 
>>>  - use bus-error reporting and counters
>>
>> I don't find support for CAN_CTRLMODE_BERR_REPORTING, apart from setting
>> the flag. If it's set bus error interrupts should be enabled or disabled
>> otherwise.
>>
>> Wolfgang.
> I expect my implementation to be complete.
> 
> 1) In esd_usb2_rx_event() I pass tx/rxerr in cf->data[6/7].
> 2) I implemented esd_usb2_get_berr_counter(). This function will 
>    return the last tx/rx error counters from the hardware that
>    are kept in priv->bec.
> 3) tx/rx error counter cannot be requested from the hardware so
>    they are stored in priv->bec when they are received from the hardware.
>    There is no way to enable or disable this behavior.
> 4) Finally I enabled the whole interface via CAN_CTRLMODE_BERR_REPORTING
>    for the CAN framework.

BERR_REPORTING != bus error counter

> I don't see where I missed anything.

The equivalent to the following SJA1000 code is missing:

           /* enable interrupts */
           if (priv->can.ctrlmode & CAN_CTRLMODE_BERR_REPORTING)
                   priv->write_reg(priv, REG_IER, IRQ_ALL);
           else
                   priv->write_reg(priv, REG_IER, IRQ_ALL & ~IRQ_BEI);

The user must now explicitly enable bus error reporting with
"ip ... type can berr_reporting on ....

Wolfgang.

 
> Matthias
> 
> 
