From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [patch] net, filter: make new test_bpf depend on networking
Date: Tue, 13 May 2014 13:07:41 -0700
Message-ID: <CAMEtUuwOY=k8hcpn4CsiNLTHgnxwidZgwXD=UsU-65+LcrmOGQ@mail.gmail.com>
References: <alpine.DEB.2.02.1405131255380.3392@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Rientjes <rientjes@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:39917 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752884AbaEMUHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 16:07:43 -0400
Received: by mail-wg0-f49.google.com with SMTP id m15so906833wgh.8
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 13:07:41 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1405131255380.3392@chino.kir.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 13, 2014 at 12:57 PM, David Rientjes <rientjes@google.com> wrote:
> CONFIG_TEST_BPF depends on CONFIG_NET, otherwise the build fails:
>
> ERROR: "sk_unattached_filter_destroy" [lib/test_bpf.ko] undefined!
> ERROR: "kfree_skb" [lib/test_bpf.ko] undefined!
> ERROR: "sk_unattached_filter_create" [lib/test_bpf.ko] undefined!
> ERROR: "sk_run_filter_int_skb" [lib/test_bpf.ko] undefined!
> ERROR: "__alloc_skb" [lib/test_bpf.ko] undefined!
>
> Add the dependency.
>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

commit 98920ba6911c7 ("net: fix test_bpf build to depend on NET")
is already in net-next.
Sorry about the breakage.

> ---
>  lib/Kconfig.debug | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -1639,6 +1639,7 @@ config TEST_USER_COPY
>  config TEST_BPF
>         tristate "Test BPF filter functionality"
>         default n
> +       depends on NET
>         depends on m
>         help
>           This builds the "test_bpf" module that runs various test vectors
