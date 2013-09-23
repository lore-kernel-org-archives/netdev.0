From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RESEND PATCH iproute2] vxlan: add ipv6 support
Date: Mon, 23 Sep 2013 13:20:49 -0700
Message-ID: <20130923132049.7fa5673e@nehalam.linuxnetplumber.net>
References: <1379730924-12433-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:36781 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007Ab3IWUUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 16:20:53 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc17so3641868pbc.32
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 13:20:52 -0700 (PDT)
In-Reply-To: <1379730924-12433-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 21 Sep 2013 10:35:24 +0800
Cong Wang <amwang@redhat.com> wrote:

> +			if (!inet_pton(AF_INET, *argv, &gaddr)) {
> +				if (!inet_pton(AF_INET6, *argv, &gaddr6)) {
> +					fprintf(stderr, "Invalid address \"%s\"\n", *argv);
> +					return -1;
> +				} else if (!IN6_IS_ADDR_MULTICAST(&gaddr6))
> +					invarg("invald group address", *argv);
> +			} else if (!IN_MULTICAST(ntohl(gaddr)))
> +					invarg("invald group address", *argv);

This is ugly, can't it be done more generically by checking for ':' in address.
Or even use getaddrinfo.

Hate to have lots of special code to handle both address types.
