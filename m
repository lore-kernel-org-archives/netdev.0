From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH v8 3/5] rxrpc: check return value of skb_to_sgvec always
Date: Mon, 15 May 2017 14:11:19 +0100
Message-ID: <30529.1494853879@warthog.procyon.org.uk>
References: <20170511194134.31183-4-Jason@zx2c4.com> <20170511194134.31183-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net,
        kernel-hardening@lists.openwall.com
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170511194134.31183-4-Jason@zx2c4.com>
Content-ID: <30528.1494853879.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jason A. Donenfeld <Jason@zx2c4.com> wrote:

> +	if (unlikely(skb_to_sgvec(skb, sg, offset, 8) < 0))
> +		goto nomem;
> ...
> +	if (unlikely(skb_to_sgvec(skb, sg, offset, len) < 0)) {
> +		if (sg != _sg)
> +			kfree(sg);
> +		goto nomem;

skb_to_sgvec() can return -EMSGSIZE in some circumstances.  You shouldn't
return -ENOMEM here in such a case.

David
