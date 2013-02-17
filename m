From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/6] qlcnic: fix unsupported CDRP command error
 message.
Date: Sat, 16 Feb 2013 21:38:56 -0800
Message-ID: <1361079536.2001.5.camel@joe-AO722>
References: <1361076831-31746-1-git-send-email-jitendra.kalsaria@qlogic.com>
	 <1361076831-31746-2-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sony.chacko@qlogic.com, Dept_NX_Linux_NIC_Driver@qlogic.com
To: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54320 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753715Ab3BQFi6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Feb 2013 00:38:58 -0500
In-Reply-To: <1361076831-31746-2-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-02-16 at 23:53 -0500, Jitendra Kalsaria wrote:
> From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> 
> Add debug messages for FW CDRP command failure.

These aren't debug messages but are more detailed.

> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
[]
> @@ -147,8 +147,36 @@ int qlcnic_82xx_issue_cmd(struct qlcnic_adapter *adapter,
>  		cmd->rsp.arg[0] = QLCNIC_RCODE_TIMEOUT;
>  	} else if (rsp == QLCNIC_CDRP_RSP_FAIL) {
>  		cmd->rsp.arg[0] = QLCRD32(adapter, QLCNIC_CDRP_ARG(1));
> -		dev_err(&pdev->dev, "failed card response code:0x%x\n",
> -			cmd->rsp.arg[0]);
> +		switch (cmd->rsp.arg[0]) {
> +		case QLCNIC_RCODE_INVALID_ARGS:
> +			dev_err(&pdev->dev, "CDRP invalid args 0x%x\n",
> +				cmd->rsp.arg[0]);
> +			break;

Not sure you care about object size much, but
it's much smaller object code to do:

	const char *fmt;
	switch (cmd->rsp.arg[0]);
	case FOO:
		fmt = "...";
		break;
	etc...
	}

	dev_err(&pdev->dev, fmt, cmd->rsp.arg[0]);

Also, the #defines are decimal, I don't know why you
print them out as hex or if you need to print them
at all really.
