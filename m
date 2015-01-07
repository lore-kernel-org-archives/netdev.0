From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -next] ip: route: add congestion control metric
Date: Tue, 6 Jan 2015 17:09:26 -0800
Message-ID: <20150106170926.5bb2d816@urahara>
References: <1420588357-17665-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:35620 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbbAGBJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 20:09:37 -0500
Received: by mail-pd0-f182.google.com with SMTP id p10so1173783pdj.13
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 17:09:37 -0800 (PST)
In-Reply-To: <1420588357-17665-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  7 Jan 2015 00:52:37 +0100
Daniel Borkmann <dborkman@redhat.com> wrote:

> +		} else if (matches(*argv, "congctl") == 0) {
> +			char cc[16];
> +			NEXT_ARG();
> +			memset(cc, 0, sizeof(cc));
> +			if (strcmp(*argv, "lock") == 0) {
> +				mxlock |= (1<<RTAX_CC_ALGO);

Unneeded paren

> +				NEXT_ARG();
> +			}
> +			strncpy(cc, *argv, sizeof(cc) - 1);
> +			if (strlen(cc) == 0)
> +				invarg("\"conctl\" value must be an algorithm name\n", *argv

Silently truncating the string is not odd. Can't we just let kernel impose
length restrictions.
