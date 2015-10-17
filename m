From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net-next] RDS: fix rds-ping deadlock over TCP transport
Date: Fri, 16 Oct 2015 18:57:10 -0700
Message-ID: <5621AAF6.9090805@oracle.com>
References: <1445041610-30133-1-git-send-email-santosh.shilimkar@oracle.com>
 <20151017014534.GH5464@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, ssantosh@kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31912 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602AbbJQB5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 21:57:16 -0400
In-Reply-To: <20151017014534.GH5464@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/2015 6:45 PM, Sowmini Varadhan wrote:
> On (10/16/15 20:26), Santosh Shilimkar wrote:
>>
>> diff --git a/net/rds/send.c b/net/rds/send.c
>> +	if (!test_bit(RDS_LL_SEND_FULL, &conn->c_flags))
>> +		queue_delayed_work(rds_wq, &conn->c_send_w, 0);
>
> A minor note- it would help to add some comments here explaining
> that the pong has already been added to the sendq earlier..
> in the case of IB, if RDS_LL_SEND_FULL has been set, it takes some
> head-scratching to figure out how the pong gets sent, and a  few
> comments could help clarify that.
>
Right. The check confused you. I will update the patch and drop
the check all together and add a jiffies for the queuing which
should take care of it. Will post v2 with that update.

> but other than that, the contents look good to me, thus
>
> Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
>
Thanks !!

regards,
Santosh
