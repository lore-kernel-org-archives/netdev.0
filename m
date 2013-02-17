From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: Re: [PATCH net-next 1/6] qlcnic: fix unsupported CDRP command error
 message.
Date: Sun, 17 Feb 2013 09:40:32 +0000
Message-ID: <BECD8E8A1B550B48A1BF97C13991F60E2B4608@avmb2.qlogic.org>
References: <1361079536.2001.5.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.32.181.183] ([216.32.181.183]:17035 "EHLO
	ch1outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755406Ab3BQJmI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Feb 2013 04:42:08 -0500
In-Reply-To: <1361079536.2001.5.camel@joe-AO722>
Content-Language: en-US
Content-ID: <7D0CC9A53EBF8C4E9B4BEC0008A5A3B3@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2/16/13 9:38 PM, "Joe Perches" <joe@perches.com> wrote:

>On Sat, 2013-02-16 at 23:53 -0500, Jitendra Kalsaria wrote:
>> From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
>> 
>> Add debug messages for FW CDRP command failure.
>
>These aren't debug messages but are more detailed.
>
>> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
>>b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
>[]
>> @@ -147,8 +147,36 @@ int qlcnic_82xx_issue_cmd(struct qlcnic_adapter
>>*adapter,
>>  		cmd->rsp.arg[0] = QLCNIC_RCODE_TIMEOUT;
>>  	} else if (rsp == QLCNIC_CDRP_RSP_FAIL) {
>>  		cmd->rsp.arg[0] = QLCRD32(adapter, QLCNIC_CDRP_ARG(1));
>> -		dev_err(&pdev->dev, "failed card response code:0x%x\n",
>> -			cmd->rsp.arg[0]);
>> +		switch (cmd->rsp.arg[0]) {
>> +		case QLCNIC_RCODE_INVALID_ARGS:
>> +			dev_err(&pdev->dev, "CDRP invalid args 0x%x\n",
>> +				cmd->rsp.arg[0]);
>> +			break;
>
>Not sure you care about object size much, but
>it's much smaller object code to do:
>
>	const char *fmt;
>	switch (cmd->rsp.arg[0]);
>	case FOO:
>		fmt = "...";
>		break;
>	etc...
>	}
>
>	dev_err(&pdev->dev, fmt, cmd->rsp.arg[0]);
>
>Also, the #defines are decimal, I don't know why you
>print them out as hex or if you need to print them
>at all really.

Joe,

Yes, your suggestion will definitely reduce object code and we don't
really need
to print them all, will print in decimal. I will re-spin series and submit
again.

Thanks!
    Jiten
