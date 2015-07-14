From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Subject: Re: [PATCH net-next v6 3/4] rocker: Handle protodown notifications.
Date: Tue, 14 Jul 2015 13:30:23 -0700
Message-ID: <CACcJQnQXL-LhA-fBK4NhPJbONPfRJ9G2QAvH5Nm42n6++0DHEg@mail.gmail.com>
References: <1436887930-3067-4-git-send-email-anuradhak@cumulusnetworks.com>
	<55A53C0B.6010807@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:33568 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752781AbbGNUaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 16:30:24 -0400
Received: by lbbyj8 with SMTP id yj8so13033793lbb.0
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 13:30:23 -0700 (PDT)
In-Reply-To: <55A53C0B.6010807@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2015 at 9:42 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 07/14/2015 06:32 PM, anuradhak@cumulusnetworks.com wrote:
>
>> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>
>
>> protodown can be set by user space applications like MLAG on detecting
>> errors on a switch port. This patch provides sample switch driver changes
>> for handling protodown. Rocker PHYS disables the port in response to
>> protodown.
>
>
>> Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
>> ---
>>   drivers/net/ethernet/rocker/rocker.c |   19 ++++++++++++++++++-
>>   1 file changed, 18 insertions(+), 1 deletion(-)
>
>
>> diff --git a/drivers/net/ethernet/rocker/rocker.c
>> b/drivers/net/ethernet/rocker/rocker.c
>> index 2d8578cade..ec950d9 100644
>> --- a/drivers/net/ethernet/rocker/rocker.c
>> +++ b/drivers/net/ethernet/rocker/rocker.c
>> @@ -3983,7 +3983,8 @@ static int rocker_port_open(struct net_device *dev)
>>
>>         napi_enable(&rocker_port->napi_tx);
>>         napi_enable(&rocker_port->napi_rx);
>> -       rocker_port_set_enable(rocker_port, true);
>> +       if (!(dev->proto_down))
>
>
>    Inner parens not needed.
Ack.

>
>> +               rocker_port_set_enable(rocker_port, true);
>>         netif_start_queue(dev);
>>         return 0;
>>
>> @@ -4167,6 +4168,21 @@ static int rocker_port_get_phys_port_name(struct
>> net_device *dev,
>>         return err ? -EOPNOTSUPP : 0;
>>   }
>>
>> +static int rocker_port_change_proto_down(struct net_device *dev,
>> +                                        bool proto_down)
>> +{
>> +       struct rocker_port *rocker_port = netdev_priv(dev);
>> +
>> +       if (rocker_port->dev->flags & IFF_UP) {
>> +               if (proto_down)
>> +                       rocker_port_set_enable(rocker_port, false);
>> +               else
>> +                       rocker_port_set_enable(rocker_port, true);
>
>
>    Why not:
>
>                 rocker_port_set_enable(rocker_port, !proto_down);
yes, that would be better. thanks for the review.
>
> [...]
>
> MBR, Sergei
>
