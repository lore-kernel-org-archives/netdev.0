From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 net-next 3/4] soreuseport: setsockopt
 SO_ATTACH_REUSEPORT_[CE]BPF
Date: Mon, 4 Jan 2016 12:11:50 -0800
Message-ID: <20160104201149.GA33051@ast-mbp.thefacebook.com>
References: <1451924798-15136-1-git-send-email-kraigatgoog@gmail.com>
 <1451924798-15136-4-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35018 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753368AbcADULn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 15:11:43 -0500
Received: by mail-pf0-f171.google.com with SMTP id 78so209173185pfw.2
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 12:11:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1451924798-15136-4-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 04, 2016 at 11:26:37AM -0500, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
> 
> Expose socket options for setting a classic or extended BPF program
> for use when selecting sockets in an SO_REUSEPORT group.  These options
> can be used on the first socket to belong to a group before bind or
> on any socket in the group after bind.
> 
> This change includes refactoring of the existing sk_filter code to
> allow reuse of the existing BPF filter validation checks.
> 
> Signed-off-by: Craig Gallek <kraig@google.com>
...
> +	/* temporarily advance data past protocol header */
> +	if (!pskb_may_pull(skb, hdr_len) || !pskb_pull(skb, hdr_len)) {
> +		consume_skb(nskb);
> +		return NULL;
> +	}

pskb_pull() includes pskb_may_pull().
