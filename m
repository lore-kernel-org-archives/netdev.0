From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net v5] bpf: add helper to compare network namespaces
Date: Thu, 16 Feb 2017 16:24:23 +1300
Message-ID: <877f4q95so.fsf@xmission.com>
References: <1487208564-4666-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net, ast@kernel.org,
        daniel@iogearbox.net, tj@kernel.org, luto@amacapital.net
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:47899 "EHLO
        out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753061AbdBPD3B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 22:29:01 -0500
In-Reply-To: <1487208564-4666-1-git-send-email-dsa@cumulusnetworks.com> (David
        Ahern's message of "Wed, 15 Feb 2017 17:29:24 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsa@cumulusnetworks.com> writes:

> In cases where bpf programs are looking at sockets and packets
> that belong to different netns, it could be useful to compare the
> network namespace of the socket or packet
>
> Introduce bpf_sk_netns_cmp and bpf_skb_netns_cmp helpers to compare
> network namespace of the socket or skb to the namespace parameters
> in a prorgam.

The code for bpf_sk_netns_cmp looks good.

I don't feel comfortable with bpf_skb_netns_cmp.  There are two
issues:

  (a) skb->dev is not reliably set and does not have reliable semantics
  in different parts of the network stack.  Making bpf_skb_netns_cmp not
  work reliably for output packets for example.

  (b) Every path that processes a network packet in the network stack
  now has a struct net passed in the function arguments.  Either
  directly or in a function that is passed through.  Making it
  unambiguous and simple to get the struct net.

So I recommend a function bpf_context_cmp.  Which looks a net passed
into the bpf filter of skbs.  That should be 100% reliable and quite
straight forward to implement today.

Eric
