From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net v5] bpf: add helper to compare network namespaces
Date: Thu, 16 Feb 2017 21:01:54 -0700
Message-ID: <16fcf613-fc8d-e2a1-5f49-40ddbade65b5@cumulusnetworks.com>
References: <1487208564-4666-1-git-send-email-dsa@cumulusnetworks.com>
 <58A57A13.9070906@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, tj@kernel.org, luto@amacapital.net,
        ebiederm@xmission.com
To: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:34195 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754684AbdBQEB4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 23:01:56 -0500
Received: by mail-pg0-f52.google.com with SMTP id z67so11801997pgb.1
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 20:01:56 -0800 (PST)
In-Reply-To: <58A57A13.9070906@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/16/17 3:08 AM, Daniel Borkmann wrote:
> Is there anything that speaks against doing the comparison itself
> outside of the helper? Meaning, the helper would get a buffer
> passed from stack f.e. struct foo { u64 ns_dev; u64 ns_ino; }
> and fills both out with the netns info belonging to the sk/skb.

How do you handle CONFIG_NET_NS not set?

You call something like bpf_get_netns_id(sk, &foo), it has to exist
regardless of the config. What should it return if netns is disabled?
