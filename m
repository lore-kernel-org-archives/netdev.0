From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: NAPI on USB network drivers
Date: Wed, 25 Jan 2017 14:33:51 +0100
Message-ID: <65d97336-d3c8-0fe7-659a-88ddecd1b13e@hartkopp.net>
References: <1485336881.16604.2.camel@suse.com>
 <0835B3720019904CB8F7AA43166CEEB201A134A7@RTITMBSV06.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
        Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB201A134A7-JIZ+AM9kKNzKeZCINmmWEypo8c9IxeqyAjHCUHv49ws@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/25/2017 10:39 AM, Hayes Wang wrote:
> Oliver Neukum [mailto:oneukum-IBi9RG/b67k@public.gmane.org]
>> Sent: Wednesday, January 25, 2017 5:35 PM
> [...]
>> looking at r8152 I noticed that it uses NAPI. I never considered
>> this for the generic USB networking code as you cannot disable
>> interrupts for USB. Is it still worth it? What are the benefits?
>
> You could use napi_gro_receive() and it influences the performance.

Another positive effect with NAPI is that you won't face out-of-order 
ethernet frames as you get with non-NAPI drivers, e.g. ax88179_178a

http://marc.info/?l=linux-can&m=148049063812807&w=2

We have the issue with CAN drivers where all USB drivers and >90% of the 
I/O mapped drivers do not use NAPI.

I wonder whether it makes sense to add NAPI to a driver which only has 
ONE RX buffer ... but when searching for a solution for o-o-o frames I 
was always pointed to NAPI.

Regards,
Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
