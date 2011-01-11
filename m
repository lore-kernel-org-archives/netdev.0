From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH 3/3] can: at91_can: make can_id of mailbox 0 configurable
Date: Tue, 11 Jan 2011 13:27:45 +0100
Message-ID: <4D2C4CC1.4070109@grandegger.com>
References: <1294741688-22699-1-git-send-email-mkl@pengutronix.de>	<1294741688-22699-4-git-send-email-mkl@pengutronix.de>	<4D2C42F0.5080703@grandegger.com>
	<4D2C4586.60207@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D2C4586.60207-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

On 01/11/2011 12:56 PM, Marc Kleine-Budde wrote:
> On 01/11/2011 12:45 PM, Wolfgang Grandegger wrote:
>> On 01/11/2011 11:28 AM, Marc Kleine-Budde wrote:
>>> Due to a chip bug (errata 50.2.6.3 & 50.3.5.3 in
>>> "AT91SAM9263 Preliminary 6249H-ATARM-27-Jul-09") the contents of mailbox
>>> 0 may be send under certain conditions (even if disabled or in rx mode).
>>>
>>> The workaround in the errata suggests not to use the mailbox and load it
>>> with a unused identifier.
>>>
>>> This patch implements the second part of the workaround. A sysfs entry
>>> "mb0_id" is introduced. While the interface is down it can be used to
>>> configure the can_id of mailbox 0. The default value id 0x7ff.
>>>
>>> In order to use an extended can_id add the CAN_EFF_FLAG (0x80000000U)
>>> to the can_id. Example:
>>>
>>> - standard id 0x7ff:
>>> echo 0x7ff      > /sys/class/net/can0/mb0_id
>>>
>>> - extended if 0x1fffffff:
>               ^^
> I've fixed the typo on my git repo. I'll send an updated series later.
> 
>>> echo 0x9fffffff > /sys/class/net/can0/mb0_id
>>
>> As this is a device specific property, I think it should go into
>> /sys/class/net/can0/device/.
> 
> The attribute goes autoamtically to /sys/class/net/can0 if you add it to
> the driver via:
> 
> +       dev->sysfs_groups[0] = &at91_sysfs_attr_group;
> 
> I've copied this from the janz-ican3 driver[1].

Oh, I missed that. And also the Softing driver does it that way :-(. The
member has the comment:

  /* space for optional device, statistics, and wireless sysfs groups */
  const struct attribute_group *sysfs_groups[4];

Therefore it seems to be legal to use it for device specific properties.

Wolfgang.
