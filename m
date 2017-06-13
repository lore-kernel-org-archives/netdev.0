From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 04/15] bpf: Sample bpf program to set
 SYN/SYN-ACK RTOs
Date: Tue, 13 Jun 2017 17:13:37 -0400 (EDT)
Message-ID: <20170613.171337.1098962047973045223.davem@davemloft.net>
References: <20170613180004.3008403-1-brakmo@fb.com>
        <20170613180004.3008403-5-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, bmatheny@fb.com,
        ast@fb.com, daniel@iogearbox.net, dsa@cumulusnetworks.com
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51172 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752327AbdFMVNt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 17:13:49 -0400
In-Reply-To: <20170613180004.3008403-5-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Tue, 13 Jun 2017 10:59:53 -0700

> +
> +	// Check for TIMEOUT_INIT operation and IPv6 addresses
> +	if (op == BPF_SOCKET_OPS_TIMEOUT_INIT &&
> +		skops->family == AF_INET6) {
> +
> +		// If the first 5.5 bytes of the IPv6 address are the same
> +		// then both hosts are in the same datacenter
> +		// so use an RTO of 10ms
> +		if (skops->local_ip6[0] == skops->remote_ip6[0] &&
> +		    (skops->local_ip6[1] & 0xfff00000) ==
> +		    (skops->remote_ip6[1] & 0xfff00000))
> +			rv = 10;
> +	}

I know this is just a sample program, but please do not use C++ comments
in C code.

Thank you.
