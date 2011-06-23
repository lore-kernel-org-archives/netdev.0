From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH] net/usb: kalmia: Various fixes for better support of
 non-x86 architectures.
Date: Thu, 23 Jun 2011 18:55:12 +0400
Message-ID: <4E0353D0.1060604@ru.mvista.com>
References: <Pine.LNX.4.44L0.1106231025340.2033-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sshtylyov@mvista.com>,
	"Marius B. Kotsbak" <marius.kotsbak@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, "Marius B. Kotsbak" <marius@kotsbak.com>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42862 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754899Ab1FWO5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 10:57:01 -0400
In-Reply-To: <Pine.LNX.4.44L0.1106231025340.2033-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Stern wrote:

>>> -Support for big endian.
>>> -Do not use USB buffers at the stack.
>>> -Safer/more efficient code for local constants.

>>> Signed-off-by: Marius B. Kotsbak<marius@kotsbak.com>

>>> ---
>>>   drivers/net/usb/kalmia.c |   40 ++++++++++++++++++++++++----------------
>>>   1 files changed, 24 insertions(+), 16 deletions(-)

>>> diff --git a/drivers/net/usb/kalmia.c b/drivers/net/usb/kalmia.c
>>> index d965fb1..d4edeb2 100644
>>> --- a/drivers/net/usb/kalmia.c
>>> +++ b/drivers/net/usb/kalmia.c
>>> @@ -100,27 +100,35 @@ kalmia_send_init_packet(struct usbnet *dev, u8 *init_msg, u8 init_msg_len,
>>>   static int
>>>   kalmia_init_and_get_ethernet_addr(struct usbnet *dev, u8 *ethernet_addr)
>>>   {
>>> -	char init_msg_1[] =
>>> +	const static char init_msg_1[] =
>>>   		{ 0x57, 0x50, 0x04, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00,
>>>   		0x00, 0x00 };
>>> -	char init_msg_2[] =
>>> +	const static char init_msg_2[] =
>>>   		{ 0x57, 0x50, 0x04, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0xf4,
>>>   		0x00, 0x00 };

>>     Actually 'const' alone should've been enough for the variable to be placed 
>> in the data section ISO stack.

> I don't understand what "ISO stack" means here.

    ISO == instead of.

> I would think that "const" might or might not cause the array to be 
> allocated statically.

    At least with gcc, it will be allocated statically.

> Alan Stern

WBR, Sergei
