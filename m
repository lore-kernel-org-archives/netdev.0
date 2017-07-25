From: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
Subject: Re: [PATCH 12/13] net: dsa: lan9303: Added "stp_enable" sysfs
 attribute
Date: Tue, 25 Jul 2017 10:34:50 +0200
Message-ID: <576f8440-bc05-03b9-7401-d8e83a49aa7e@zenitel.com>
References: <08c405e265564e47a4649f7fe264a908@nooslMX1.zenitelcss.com>
 <27565dee-8fc5-79dc-e272-a8cf8556e3a5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, <corbet@lwn.net>,
        <andrew@lunn.ch>, <vivien.didelot@savoirfairelinux.com>,
        <davem@davemloft.net>, <kernel@pengutronix.de>,
        <linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <27565dee-8fc5-79dc-e272-a8cf8556e3a5@gmail.com>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 24. juli 2017 18:55, Florian Fainelli wrote:
> On 07/20/2017 06:42 AM, Egil Hjelmeland wrote:
>> Must be set to 1 by user space when STP is used on the lan9303.
>> If bridging without local STP, leave at 0, so external STP BPDUs
>> are forwarded.
>>
>> Hopefully the kernel can be improved so the driver can handle this
>> without user intervention, and this control can be removed.
> 
> Same here, we can't have a driver-specific sysfs attribute just for
> this, either we find a way to have the bridge's STP settings propagate
> correctly to the switch driver, or you have to make better decisions
> based on hints/calls you are getting from switchdev -> dsa -> driver.
> 

I can't see that the driver gets enough information now. But please
correct me if I am wrong. Problem is that when disabling
multicast_flood, then the BPDUs are not forwarded by the SW bridge,
so I can not have the 01:80:c2:00:00:00 entry in always.

Perhaps the kernel could do port_fdb_add/del on 01:80:c2:00:00:00
when STP is turned on/off? Or could that break other DSA chips?

When we are at it, it would be good if the driver could return some
capability information to the kernel, so it can adapt accordingly.
It does not feel right that user space has to disable the xxxx_flood
flags, the kernel should be able to figure that out by it self.

DISCLAIMER:
This e-mail may contain confidential and privileged material for the sole use of the intended recipient. Any review, use, distribution or disclosure by others is strictly prohibited. If you are not the intended recipient (or authorized to receive for the recipient), please contact the sender by reply e-mail and delete all copies of this message.
