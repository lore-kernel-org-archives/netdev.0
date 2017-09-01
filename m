From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [net-next PATCH] bpf: sockmap update/simplify memory accounting
 scheme
Date: Fri, 1 Sep 2017 12:25:57 -0700
Message-ID: <b91b19a8-b60b-2483-e878-d1f1e2b8e501@fb.com>
References: <20170901182926.8981.77450.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <daniel@iogearbox.net>
To: John Fastabend <john.fastabend@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:49556 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752170AbdIAT0U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 15:26:20 -0400
In-Reply-To: <20170901182926.8981.77450.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/1/17 11:29 AM, John Fastabend wrote:
> Instead of tracking wmem_queued and sk_mem_charge by incrementing
> in the verdict SK_REDIRECT paths and decrementing in the tx work
> path use skb_set_owner_w and sock_writeable helpers. This solves
> a few issues with the current code. First, in SK_REDIRECT inc on
> sk_wmem_queued and sk_mem_charge were being done without the peers
> sock lock being held. Under stress this can result in accounting
> errors when tx work and/or multiple verdict decisions are working
> on the peer psock.
>
> Additionally, this cleans up the code because we can rely on the
> default destructor to decrement memory accounting on kfree_skb. Also
> this will trigger sk_write_space when space becomes available on
> kfree_skb() which wasn't happening before and prevent __sk_free
> from being called until all in-flight packets are completed.
>
> Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

thanks. it's cleaner indeed.

Acked-by: Alexei Starovoitov <ast@kernel.org>
