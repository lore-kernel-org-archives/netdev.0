From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool 2/3] ethtool: add support for external loopback.
Date: Tue, 04 Oct 2011 23:12:23 +0100
Message-ID: <1317766343.2751.17.camel@bwh-desktop>
References: <1316514695-17157-1-git-send-email-sucheta.chakraborty@qlogic.com>
	 <1316514695-17157-3-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:5061 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932820Ab1JDWM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 18:12:26 -0400
In-Reply-To: <1316514695-17157-3-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-09-20 at 03:31 -0700, Sucheta Chakraborty wrote:
> External loopback will be performed in addition to other offline tests.
> User need to pass new parameter "external_lb" for the same.
> 
> Reqd. man page changes included.

Applied, but:

[...]
> @@ -1689,6 +1692,9 @@ static int dump_test(struct ethtool_drvinfo *info, struct ethtool_test *test,
>  
>  	rc = test->flags & ETH_TEST_FL_FAILED;
>  	fprintf(stdout, "The test result is %s\n", rc ? "FAIL" : "PASS");
> +	fprintf(stdout, "External loopback test is %s\n",
> +		test->flags & ETH_TEST_FL_EXTERNAL_LB_DONE ? "executed" :
> +							"not executed");
>  
>  	if (info->testinfo_len)
>  		fprintf(stdout, "The test extra info:\n");

1. This message should say 'was', not 'is'.

2. There are undoubtedly scripts that parse the output of ethtool -t.
We might break them if we add a line to the output of existing commands.
I've made this conditional on test_type == EXTERNAL_LB.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
