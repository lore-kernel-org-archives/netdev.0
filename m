From: David Miller <davem@davemloft.net>
Subject: Re: [V2 6/7] hvsock: introduce Hyper-V VM Sockets feature
Date: Wed, 15 Jul 2015 21:19:16 -0700 (PDT)
Message-ID: <20150715.211916.1258342954251964451.davem@davemloft.net>
References: <1436868048-17875-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, stephen@networkplumber.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org, olaf@aepfle.de,
	apw@canonical.com, jasowang@redhat.com, kys@microsoft.com,
	pebolle@tiscali.nl
To: decui@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436868048-17875-1-git-send-email-decui@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dexuan Cui <decui@microsoft.com>
Date: Tue, 14 Jul 2015 03:00:48 -0700

> +	pr_debug("hvsock_sk_destruct: called\n");

Debug logging just to state that a function is called is not appropriate,
we have very sophisticated tracing facilities in the kernel that can do
that transparently, and more.

PLease remove this.

> +	if (hvsk->channel) {
> +		pr_debug("hvsock_sk_destruct: calling vmbus_close()\n");

Likewise, these kinds of debug logs are totally inappropriate.

> +static int hvsock_release(struct socket *sock)
> +{
> +	/* sock->sk is NULL, if accept() is interrupted by a signal */
> +	if (sock->sk) {
> +		__hvsock_release(sock->sk);
> +		sock->sk = NULL;
> +	}
> +
> +	sock->state = SS_FREE;
> +	pr_debug("hvsock_release called\n\n");

Likewise.
