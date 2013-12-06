From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: Re: [PATCH] can: ems_usb: fix a leak in ems_usb_start_xmit()
Date: Sat, 07 Dec 2013 02:57:47 +0400
Message-ID: <52A2566B.3030302@ispras.ru>
References: <1386363082-15144-1-git-send-email-khoroshilov@ispras.ru> <6e046a57-0383-41ae-bc8c-8eaaa4709a4c@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ldv-project@linuxtesting.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <6e046a57-0383-41ae-bc8c-8eaaa4709a4c@email.android.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07.12.2013 02:28, Oliver Hartkopp wrote:
> Alexey Khoroshilov <khoroshilov@ispras.ru> schrieb:
>> There is spare code with obvious misprint in ems_usb_start_xmit():
>> usb_free_urb() should be used to deallocate urb instead of
>> usb_unanchor_urb().
>>
>> Found by Linux Driver Verification project (linuxtesting.org).
>>
>> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
>> ---
>> drivers/net/can/usb/ems_usb.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/can/usb/ems_usb.c
>> b/drivers/net/can/usb/ems_usb.c
>> index 5f9a7ad9b964..beae1ec255f4 100644
>> --- a/drivers/net/can/usb/ems_usb.c
>> +++ b/drivers/net/can/usb/ems_usb.c
>> @@ -798,7 +798,7 @@ static netdev_tx_t ems_usb_start_xmit(struct
>> sk_buff *skb, struct net_device *ne
>> 	 * allowed (MAX_TX_URBS).
>> 	 */
>> 	if (!context) {
>> -		usb_unanchor_urb(urb);
>> +		usb_free_urb(urb);
>> 		usb_free_coherent(dev->udev, size, buf, urb->transfer_dma);
>>
> looks like you are introducing a new use after free problem here ...
>
You are right. usb_free_urb(urb) should be one line below.

I will resend the patch with one more similar fix in the driver.
