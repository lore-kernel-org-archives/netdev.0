From: David Miller <davem@davemloft.net>
Subject: Re: Update ip command line processing
Date: Thu, 20 Dec 2007 15:21:21 -0800 (PST)
Message-ID: <20071220.152121.188610437.davem@davemloft.net>
References: <20071218085730.GA10765@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	apw@us.ibm.com
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51123
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756051AbXLTXVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 18:21:22 -0500
In-Reply-To: <20071218085730.GA10765@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Tue, 18 Dec 2007 17:57:32 +0900

> @@ -1414,9 +1414,16 @@ late_initcall(ip_auto_config);
>   */
>  static int __init ic_proto_name(char *name)
>  {
> +	if (!name) {
> +		return 1;
> +	}

I do not see any circumstance under which this pointer can
be NULL.  Judging by your other changes, I think you mean
to use "!*name" here.

Maybe:

	if (*name == '\0')

would make it clearer what you're checking for, an
empty string.

Otherwise I'm fine with your change.
