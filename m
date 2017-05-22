From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] vsock: use new wait API for vsock_stream_sendmsg()
Date: Mon, 22 May 2017 14:39:51 -0400 (EDT)
Message-ID: <20170522.143951.945710292413025877.davem@davemloft.net>
References: <1495218119-12358-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stefanha@redhat.com, jhansen@vmware.com,
        mst@redhat.com, imbrenda@linux.vnet.ibm.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55008 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759362AbdEVSjx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 14:39:53 -0400
In-Reply-To: <1495218119-12358-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 19 May 2017 11:21:59 -0700

> As reported by Michal, vsock_stream_sendmsg() could still
> sleep at vsock_stream_has_space() after prepare_to_wait():
> 
>   vsock_stream_has_space
>     vmci_transport_stream_has_space
>       vmci_qpair_produce_free_space
>         qp_lock
>           qp_acquire_queue_mutex
>             mutex_lock
> 
> Just switch to the new wait API like we did for commit
> d9dc8b0f8b4e ("net: fix sleeping for sk_wait_event()").
> 
> Reported-by: Michal Kubecek <mkubecek@suse.cz>
> Cc: Stefan Hajnoczi <stefanha@redhat.com>
> Cc: Jorgen Hansen <jhansen@vmware.com>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thank you.
