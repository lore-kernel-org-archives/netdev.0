From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 2/3] can: fix oops caused by wrong rtnl dellink usage
Date: Thu, 23 Jun 2016 15:01:23 +0200
Message-ID: <0e51107f-a381-6c94-0079-d0ed415d8bcc@hartkopp.net>
References: <1466673741-23115-1-git-send-email-mkl@pengutronix.de>
 <1466673741-23115-3-git-send-email-mkl@pengutronix.de>
 <e092c3e9-56f3-f765-a9ef-89697ec46e16@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, stable@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.221]:41239 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256AbcFWNBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 09:01:52 -0400
In-Reply-To: <e092c3e9-56f3-f765-a9ef-89697ec46e16@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/23/2016 02:55 PM, Sergei Shtylyov wrote:
> Hello.
>
> On 6/23/2016 12:22 PM, Marc Kleine-Budde wrote:
>
>> From: Oliver Hartkopp <socketcan@hartkopp.net>
>>
>> For 'real' hardware CAN devices the netlink interface is used to set CAN
>> specific communication parameters. Real CAN hardware can not be
>> created nor
>> removed with the ip tool ...
>>
>> This patch adds a private dellink function for the CAN device driver
>> interface
>> that does just nothing.
>>
>> It's a follow up to commit 993e6f2fd ("can: fix oops caused by wrong rtnl
>> newlink usage") but for dellink.
>>
>> Reported-by: ajneu <ajneu1@gmail.com>
>> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
>> Cc: <stable@vger.kernel.org>
>> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
>> ---
>>  drivers/net/can/dev.c | 6 ++++++
>>  1 file changed, 6 insertions(+)
>>
>> diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
>> index 348dd5001fa4..ad535a854e5c 100644
>> --- a/drivers/net/can/dev.c
>> +++ b/drivers/net/can/dev.c
>> @@ -1011,6 +1011,11 @@ static int can_newlink(struct net *src_net,
>> struct net_device *dev,
>>      return -EOPNOTSUPP;
>>  }
>>
>> +static void can_dellink(struct net_device *dev, struct list_head *head)
>> +{
>> +    return;
>
>    Why?
>

http://marc.info/?l=linux-can&m=146651600421205&w=2

The same reason as for commit 993e6f2fd.

Regards,
Oliver

>> +}
>> +
>>  static struct rtnl_link_ops can_link_ops __read_mostly = {
>>      .kind        = "can",
>>      .maxtype    = IFLA_CAN_MAX,
> [...]
>
> MBR, Sergei
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-can" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
