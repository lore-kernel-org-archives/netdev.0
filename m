From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 2/3] can: fix oops caused by wrong rtnl dellink usage
Date: Thu, 23 Jun 2016 18:45:58 +0200
Message-ID: <a1bd95b5-ea93-0e99-7784-dad393240f06@hartkopp.net>
References: <1466673741-23115-1-git-send-email-mkl@pengutronix.de>
 <1466673741-23115-3-git-send-email-mkl@pengutronix.de>
 <e092c3e9-56f3-f765-a9ef-89697ec46e16@cogentembedded.com>
 <0e51107f-a381-6c94-0079-d0ed415d8bcc@hartkopp.net>
 <f4b685f9-a2ad-d3cc-1204-f457705467df@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, stable@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.162]:52217 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852AbcFWQqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 12:46:24 -0400
In-Reply-To: <f4b685f9-a2ad-d3cc-1204-f457705467df@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/23/2016 03:09 PM, Sergei Shtylyov wrote:

>>>> +static void can_dellink(struct net_device *dev, struct list_head
>>>> *head)
>>>> +{
>>>> +    return;
>>>
>>>    Why?
>>>
>>
>> http://marc.info/?l=linux-can&m=146651600421205&w=2
>>
>> The same reason as for commit 993e6f2fd.
>
>    I was asking just about the useless *return* statement...
>

Ah!

I did some investigation before whether using 'return' in empty void 
functions or not.

static void can_dellink(struct net_device *dev, struct list_head *head);

and

static void can_dellink(struct net_device *dev, struct list_head *head)
{
	return;
}

do the same job, right?

But the first one looks like a forward declaration and you would try to 
find the 'implementing' function then.

Of course you can write less code and both implementations are correct - 
but this representation makes it pretty clear that here's nothing to do :-)

Regards,
Oliver
