From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] net: ptp: oki-semi: fix build dependency
Date: Mon, 31 Mar 2014 11:21:54 +0200
Message-ID: <20140331092153.GC6867@netboy>
References: <1396247539-27298-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:37890 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753495AbaCaJV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 05:21:59 -0400
Received: by mail-we0-f179.google.com with SMTP id x48so4537518wes.10
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 02:21:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1396247539-27298-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 30, 2014 at 11:32:19PM -0700, Alexei Starovoitov wrote:

> -	depends on PCI && (X86 || COMPILE_TEST)
> +	depends on PCI && NETWORK_PHY_TIMESTAMPING && (X86 || COMPILE_TEST)

This is not the way to fix it.

Enabling NETWORK_PHY_TIMESTAMPING puts extra checks into the hot path
for every skb passed to netif_receive_skb(). It only makes sense to
pay this extra cost if you actually have a time stamping PHY.

So instead, move the classifier routine out of timestamping.c to a
place where it is always compiled into the stack.

Thanks,
Richard
