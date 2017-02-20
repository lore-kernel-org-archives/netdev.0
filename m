From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: return errno -ENOMEM when exceeding RLIMIT_MEMLOCK
Date: Mon, 20 Feb 2017 16:57:34 +0100
Message-ID: <58AB11EE.4050905@iogearbox.net>
References: <148760491056.17885.7344022207445355578.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54493 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752767AbdBTP6l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 10:58:41 -0500
In-Reply-To: <148760491056.17885.7344022207445355578.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/2017 04:35 PM, Jesper Dangaard Brouer wrote:
> It is confusing users of samples/bpf that exceeding the resource
> limits for RLIMIT_MEMLOCK result in an "Operation not permitted"
> message.  This is due to bpf limits check return -EPERM.
>
> Instead return -ENOMEM, like most other users of this API.
>
> Fixes: aaac3ba95e4c ("bpf: charge user for creation of BPF maps and programs")
> Fixes: 6c9059817432 ("bpf: pre-allocate hash map elements")
> Fixes: 5ccb071e97fb ("bpf: fix overflow in prog accounting")

Btw, last one just moves the helper so fixes doesn't really apply
there, but apart from that this is already uapi exposed behavior
like this for ~1.5yrs, so unfortunately too late to change now. I
think the original intention (arguably confusing in this context)
was that user doesn't have (rlimit) permission to allocate this
resource.

Thanks,
Daniel
