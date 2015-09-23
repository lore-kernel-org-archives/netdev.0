From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netpoll: Close race condition between poll_one_napi
 and napi_disable
Date: Wed, 23 Sep 2015 11:03:10 -0700 (PDT)
Message-ID: <20150923.110310.498137907112491653.davem@davemloft.net>
References: <20150922190154.GC31679@hmsreliant.think-freely.org>
	<1442952096-31430-1-git-send-email-nhorman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44182 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbbIWSDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 14:03:11 -0400
In-Reply-To: <1442952096-31430-1-git-send-email-nhorman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@redhat.com>
Date: Tue, 22 Sep 2015 16:01:36 -0400

> -	set_bit(NAPI_STATE_NPSVC, &napi->state);
> +	/*
> +	 * If we set this bit but see that it has already been set,
> +	 * that indicates that napi has been disabled and we need
> +	 * to abort this operation
> + 	 */
> +
> +	if(test_and_set_bit(NAPI_STATE_NPSVC, &napi->state))
> +		goto out;
>  

Networking comments should be styled:

	/* Like
	 * this.
	 */

Also you need a space after the "if" and before the openning parenthesis.

And like Stephen I think the empty line between the comment and the
if() statement is superfluous and eats up precious vertical space on
the screen :-)

Thanks.
