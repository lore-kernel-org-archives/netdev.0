From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] prevent the read ahead of /proc/slabinfo in ss
Date: Mon, 09 Feb 2015 11:16:18 -0800 (PST)
Message-ID: <20150209.111618.1959932896181412008.davem@davemloft.net>
References: <1423481830-9599-1-git-send-email-brytonlee01@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: brytonlee01@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48322 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833AbbBITQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 14:16:19 -0500
In-Reply-To: <1423481830-9599-1-git-send-email-brytonlee01@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bryton Lee <brytonlee01@gmail.com>
Date: Mon,  9 Feb 2015 19:37:10 +0800

> @@ -617,6 +617,7 @@ struct slabstat
>  };
>  
>  struct slabstat slabstat;
> +int slabstat_valid = 0;
>  
>  static const char *slabstat_ids[] =
>  {

Nothing sets this to a non-zero value.  If nothing is going to set it to
a non-zero value, the code it guards should simple be removed instead.

Otherwise, nothing uses this variable outside of this file, and if
that's intentional it should be static.
