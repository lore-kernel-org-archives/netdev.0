From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv2 net-next iproute2] gre: add support for ERSPAN tunnel
Date: Thu, 10 Aug 2017 15:12:13 -0700
Message-ID: <20170810151213.095a4505@xeon-e3>
References: <1502396067-21274-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Meenakshi Vohra <mvohra@vmware.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34887 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752440AbdHJWMV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 18:12:21 -0400
Received: by mail-pf0-f179.google.com with SMTP id t86so8289384pfe.2
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2017 15:12:21 -0700 (PDT)
In-Reply-To: <1502396067-21274-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Aug 2017 13:14:27 -0700
William Tu <u9012063@gmail.com> wrote:

> +
> +		if (greinfo[IFLA_GRE_ERSPAN_INDEX])
> +			erspan_idx = rta_getattr_u32(greinfo[IFLA_GRE_ERSPAN_INDEX]);
>  	}

Are you missing a ntohl() here?

It is encoded as htonl() when sending to kernel.

 		addattr32(n, 1024, IFLA_GRE_FWMARK, fwmark);
+		addattr32(n, 1024, IFLA_GRE_ERSPAN_INDEX, htonl(erspan_idx));

Is erspan_idx == 0 a reserved value?
You should only send erspan_idx to kernel if it is given on command line.
