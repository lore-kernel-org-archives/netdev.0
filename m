From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [V2 PATCH 9/9] vhost: zerocopy: poll vq in zerocopy callback
Date: Thu, 17 May 2012 08:34:22 -0700
Message-ID: <1337268862.10741.58.camel@oc3660625478.ibm.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
	 <20120502034254.11782.27314.stgit@amd-6168-8-1.englab.nay.redhat.com>
	 <1337100630.8220.4.camel@oc3660625478.ibm.com> <4FB317C8.90002@redhat.com>
	 <1337181027.10741.13.camel@oc3660625478.ibm.com>
	 <20120516151444.GC9934@redhat.com>
	 <1337189525.10741.24.camel@oc3660625478.ibm.com>
	 <4FB4677A.8020402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:56529 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760008Ab2EQPep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 11:34:45 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <mashirle@us.ibm.com>;
	Thu, 17 May 2012 09:34:43 -0600
In-Reply-To: <4FB4677A.8020402@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-17 at 10:50 +0800, Jason Wang wrote:
> The problem is we may stop the tx queue when there no enough capacity
> to 
> place packets, at this moment  we depends on the tx interrupt to 
> re-enable the tx queue. So if we didn't poll the vhost during
> callback, 
> guest may lose the tx interrupt to re-enable the tx queue which could 
> stall the whole tx queue. 

VHOST_MAX_PEND should handle the capacity. 

Hasn't the above situation been handled in handle_tx() code?:
...
                        if (unlikely(num_pends > VHOST_MAX_PEND)) {
                                tx_poll_start(net, sock);
                                set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
                                break;
                        }
...

Thanks
Shirley
