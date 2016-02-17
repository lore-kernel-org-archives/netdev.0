From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] nsh: encapsulation module
Date: Tue, 16 Feb 2016 19:31:33 -0800
Message-ID: <20160217033132.GA47212@ast-mbp.thefacebook.com>
References: <1455220626-28244-1-git-send-email-brussell@brocade.com>
 <1455220626-28244-2-git-send-email-brussell@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Brian Russell <brussell@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34072 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755640AbcBQDaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 22:30:20 -0500
Received: by mail-pa0-f51.google.com with SMTP id fy10so3190480pac.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 19:30:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1455220626-28244-2-git-send-email-brussell@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 11, 2016 at 07:57:05PM +0000, Brian Russell wrote:
> Support encap/decap of Network Service Header (NSH) as defined in
> https://tools.ietf.org/html/draft-ietf-sfc-nsh-01
> 
> Includes support for Type 1 and Type 2 metadata and a simple registration
> for listeners to see decapsulated packets based on the Type/Class.
> 
> Signed-off-by: Brian Russell <brussell@brocade.com>
...
> +int nsh_register_listener(struct nsh_listener *listener)
> +{
> +	if (listener->max_ctx_hdrs > limit_ctx_hdrs)
> +		return -ENOMEM;
> +
> +	mutex_lock(&nsh_listener_mutex);
> +	list_add(&listener->list, &nsh_listeners);
> +	mutex_unlock(&nsh_listener_mutex);
> +	return 0;
> +}
> +EXPORT_SYMBOL(nsh_register_listener);
> +EXPORT_SYMBOL(nsh_unregister_listener);

looks like this patch doesn't actually implement the protocol,
but rather provides a placeholder for out of tree modules?
