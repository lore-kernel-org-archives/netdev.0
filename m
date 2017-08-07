From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH iproute2] lib: Dump ext-ack string by default
Date: Mon, 7 Aug 2017 13:36:49 -0600
Message-ID: <79db9ff1-69c3-5a16-fb67-54f1b79eb3a5@gmail.com>
References: <1502134082-4602-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35033 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751505AbdHGTgv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 15:36:51 -0400
Received: by mail-pf0-f179.google.com with SMTP id t86so5283256pfe.2
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 12:36:51 -0700 (PDT)
In-Reply-To: <1502134082-4602-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/7/17 1:28 PM, David Ahern wrote:
> @@ -99,7 +95,12 @@ static int nl_dump_ext_err(const struct nlmsghdr *nlh, nl_ext_ack_fn_t errfn)
>  			err_nlh = &err->msg;
>  	}
>  
> -	return errfn(errmsg, off, err_nlh);
> +	if (errfn)
> +		return errfn(errmsg, off, err_nlh);
> +
> +	fprintf(stderr, "Error: %s\n", errmsg);
> +
> +	return 1;


Dang it, missing an 'if (errmsg)' since it does not have to exist. Will
send a v2
