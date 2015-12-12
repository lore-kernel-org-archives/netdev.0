From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net-next.git) 16/18] stmmac: do not perform zero-copy
 for rx frames
Date: Fri, 11 Dec 2015 20:09:29 -0500 (EST)
Message-ID: <20151211.200929.1933211408365625907.davem@davemloft.net>
References: <1449650274-14896-1-git-send-email-peppe.cavallaro@st.com>
	<1449650274-14896-17-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexandre.torgue@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58930 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753755AbbLLBJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 20:09:31 -0500
In-Reply-To: <1449650274-14896-17-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Wed, 9 Dec 2015 09:37:52 +0100

> @@ -98,6 +98,10 @@ static int buf_sz = DEFAULT_BUFSIZE;
>  module_param(buf_sz, int, S_IRUGO | S_IWUSR);
>  MODULE_PARM_DESC(buf_sz, "DMA buffer size");
>  
> +static int minrx = 256;
> +module_param(minrx, int, S_IRUGO | S_IWUSR);
> +MODULE_PARM_DESC(minrx, "Copy only tiny-frames");
> +

When you type module_param() in a network driver, you ought to receive
an electric shock in order to remind you that except in the most extreme
cases module parameters are absolutely not appropriate.

In this case we have an ethtool tunable people can use to control copy
break values like this, so use that instead.
