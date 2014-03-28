From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] vhost: fix total length when packets are too short
Date: Fri, 28 Mar 2014 16:09:40 -0400 (EDT)
Message-ID: <20140328.160940.1707102420095481862.davem@davemloft.net>
References: <20140327100026.GA30715@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20140327100026.GA30715@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 27 Mar 2014 12:00:26 +0200

> When mergeable buffers are disabled, and the
> incoming packet is too large for the rx buffer,
> get_rx_bufs returns success.
> 
> This was intentional in order for make recvmsg
> truncate the packet and then handle_rx would
> detect err != sock_len and drop it.
> 
> Unfortunately we pass the original sock_len to
> recvmsg - which means we use parts of iov not fully
> validated.
> 
> Fix this up by detecting this overrun and doing packet drop
> immediately.
> 
> CVE-2014-0077
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
> 
> Changes from v1:
> 	Fix CVE# in the commit log.
> 	Patch is unchanged.
> 
> Note: this is needed for -stable.

Applied and queued up for -stable.

> I wonder if this can still make the release.

I will try but no promises.
