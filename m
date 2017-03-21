From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/1] actions: Add support for user cookies
Date: Tue, 21 Mar 2017 14:22:02 -0700
Message-ID: <20170321142202.525fa06e@xeon-e3>
References: <1490128502-22133-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:35212 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756389AbdCUVWN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 17:22:13 -0400
Received: by mail-pg0-f45.google.com with SMTP id t143so33426429pgb.2
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 14:22:12 -0700 (PDT)
In-Reply-To: <1490128502-22133-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor style issues.

> +			if (*argv && strcmp(*argv, "cookie") == 0) {
> +				int slen;
slen is strlen() and that returns size_t not int.

> +
> +				NEXT_ARG();
> +				slen = strlen(*argv);
> +				if (slen > (TC_COOKIE_MAX_SIZE*2))

No extra (), and space around *

> +					invarg("cookie cannot exceed %d\n",
> +					       *argv);
> +
> +				if (hex2mem(*argv, act_ck, slen/2) < 0)
Space around / operator

> +					invarg("cookie must be a hex string\n",
> +					       *argv);
> +
> +				act_ck_len = slen;
> +				argc--;
> +				argv++;
> +			}
> +
> +			if (act_ck_len)
> +				addattr_l(n, MAX_MSG, TCA_ACT_COOKIE,
> +					  (const void *)&act_ck, act_ck_len);

Cast to void *  is not necessary.
