From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 15/15] bpf: Sample bpf program to set
 sndcwnd clamp
Date: Tue, 13 Jun 2017 17:32:06 -0400 (EDT)
Message-ID: <20170613.173206.1185302030405741253.davem@davemloft.net>
References: <20170613180004.3008403-1-brakmo@fb.com>
        <20170613180004.3008403-16-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, bmatheny@fb.com,
        ast@fb.com, daniel@iogearbox.net, dsa@cumulusnetworks.com
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51708 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751793AbdFMVcI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 17:32:08 -0400
In-Reply-To: <20170613180004.3008403-16-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Tue, 13 Jun 2017 11:00:04 -0700

> +SEC("sockops")
> +int bpf_clamp(struct __sk_buff *skb)
> +{
> +	struct bpf_socket_ops *skops = (struct bpf_socket_ops *) skb;
> +	char fmt1[] = "BPF command: %d\n";
> +	char fmt2[] = "  Returning %d\n";
> +	int op;
> +	int rv = 0;
> +	int bufsize = 150000;
> +	int clamp = 100;
> +	int to_init = 10;
> +
> +	// For testing purposes, only execute rest of BPF program
> +	// if neither port numberis 55601
> +	if (skops->remote_port != 55601 && skops->local_port != 55601)
> +		return -1;

Local variable ordering and C++ comments.
