From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 3/3] xfrm_{state,policy}: Allow to deleteall
 polices/states with marks
Date: Tue, 31 Oct 2017 18:13:59 +0100
Message-ID: <20171031181359.5b868f1a@shemminger-XPS-13-9360>
References: <97621e2c-30e3-aba3-ed5a-71241d94ec26@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Thomas Egerer <thomas.egerer@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:47027 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753831AbdJaROY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 13:14:24 -0400
Received: by mail-lf0-f45.google.com with SMTP id g70so19896861lfl.3
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 10:14:24 -0700 (PDT)
In-Reply-To: <97621e2c-30e3-aba3-ed5a-71241d94ec26@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Oct 2017 19:11:46 +0100
Thomas Egerer <thomas.egerer@secunet.com> wrote:

>  
> +	if (tb[XFRMA_MARK]) {
> +		int r = addattr_l(new_n, xb->size, XFRMA_MARK,
> +				(void *)RTA_DATA(tb[XFRMA_MARK]), tb[XFRMA_MARK]->rta_len);

Since addattr_l already uses const void * for the attribute argument,
the cast here is unnecessary. Also try and break long lines if possible.

Also, you should probably be using RTA_PAYLOAD() rather than dereferncing rta_len
here.
