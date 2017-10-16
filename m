From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: check for null sk before deferencing it via the call
 to sock_net
Date: Mon, 16 Oct 2017 19:32:25 +0200
Message-ID: <c50ebff0-233c-7dcf-1b80-19ac0369803a@hartkopp.net>
References: <20170908150235.2931-1-colin.king@canonical.com>
 <f5ce1047-eb37-151a-c7b7-9b47b70789f7@hartkopp.net>
 <CA+5PVA7fJfZmN-XLuqARGkWL6eY54HaRAj19K_Und3K7vAVfpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Colin King <colin.king@canonical.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        "David S . Miller" <davem@davemloft.net>,
        linux-can@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        "Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>
To: Josh Boyer <jwboyer@fedoraproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.218]:10172 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753392AbdJPRcr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 13:32:47 -0400
In-Reply-To: <CA+5PVA7fJfZmN-XLuqARGkWL6eY54HaRAj19K_Und3K7vAVfpg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/2017 06:37 PM, Josh Boyer wrote:
> On Fri, Sep 8, 2017 at 1:46 PM, Oliver Hartkopp <socketcan@hartkopp.net> wrote:
>>
>>
>> On 09/08/2017 05:02 PM, Colin King wrote:
>>>
>>> From: Colin Ian King <colin.king@canonical.com>
>>>
>>> The assignment of net via call sock_net will dereference sk. This
>>> is performed before a sanity null check on sk, so there could be
>>> a potential null dereference on the sock_net call if sk is null.
>>> Fix this by assigning net after the sk null check. Also replace
>>> the sk == NULL with the more usual !sk idiom.
>>>
>>> Detected by CoverityScan CID#1431862 ("Dereference before null check")
>>>
>>> Fixes: 384317ef4187 ("can: network namespace support for CAN_BCM
>>> protocol")
>>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
>>
>>
>> Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>
> 
> I don't see this one queued up in the net or net-next trees.  Did it
> fall through the cracks or did it get queued up elsewhere?  Seems like
> it's a good candidate to get into 4.14?

It definitely is!

Marc is our responsible guy for CAN related upstreams - but he seems to 
be busy as I already poked him here:

https://marc.info/?l=linux-can&m=150771819505097&w=2

If he doesn't send a pull request by beginning of next week, I would ask 
Dave to grab these patches - to get them into 4.14.

Best regards,
Oliver
