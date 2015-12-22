From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH 13/17] calipso: Allow request sockets to be relabelled
 by the lsm.
Date: Tue, 22 Dec 2015 14:40:02 +0100
Message-ID: <567952B2.2080905@stressinduktion.org>
References: <1450784813-18304-14-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <pmoore@redhat.com>
To: Huw Davies <huw@codeweavers.com>, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:46557 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751291AbbLVNkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 08:40:05 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 3DDB8208C7
	for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 08:40:04 -0500 (EST)
In-Reply-To: <1450784813-18304-14-git-send-email-huw@codeweavers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.12.2015 12:46, Huw Davies wrote:
>  	tot_len += sizeof(*opt2);
> -	opt2 = sock_kmalloc(sk, tot_len, GFP_ATOMIC);
> +	if (sk)
> +		opt2 = sock_kmalloc(sk, tot_len, GFP_ATOMIC);
> +	else
> +		opt2 = kmalloc(tot_len, GFP_ATOMIC);
>  	if (!opt2)
>  		return ERR_PTR(-ENOBUFS);

This change looks dangerous to me in terms of control of memory
depletion from a remote host. Could you use sk_to_full_sk and account
options towards the listener socket?
