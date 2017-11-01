From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] Add "show" subcommand to "ip fou"
Date: Wed, 1 Nov 2017 22:03:33 +0100
Message-ID: <20171101220333.5f73760f@shemminger-XPS-13-9360>
References: <BC879902-DED4-4AFC-B2AA-8C4F4C4B4C99@apple.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Greg Greenway <ggreenway@apple.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:55378 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933164AbdKAVEY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 17:04:24 -0400
Received: by mail-lf0-f68.google.com with SMTP id e143so3988468lfg.12
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 14:04:23 -0700 (PDT)
In-Reply-To: <BC879902-DED4-4AFC-B2AA-8C4F4C4B4C99@apple.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Oct 2017 13:00:47 -0700
Greg Greenway <ggreenway@apple.com> wrote:

> +	if (tb[FOU_ATTR_AF]) {
> +		family = rta_getattr_u8(tb[FOU_ATTR_AF]);
> +		if (family == AF_INET)
> +			family_str = "AF_INET";
> +		else if (family == AF_INET6)
> +			family_str = "AF_INET6";
> +		else
> +			family_str = "unknown";
> +		fprintf(fp, "af %s ", family_str);

The unwritten rule for ip commands is that the show function
must format the output with same command syntax as the other commands set/add/delete.
Since there is no "af AF_INET" option to ip fou, this breaks that convention.
Either ignore the address family, change the add command, or output with same
syntax (-6); preferably the latter.
