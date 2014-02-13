From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] vhost: fix ref cnt checking deadlock
Date: Thu, 13 Feb 2014 18:48:12 -0500 (EST)
Message-ID: <20140213.184812.213639748986818676.davem@davemloft.net>
References: <1392284448-1977-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, qinchuanyu@huawei.com
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1392284448-1977-1-git-send-email-mst@redhat.com>
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
Date: Thu, 13 Feb 2014 11:42:05 +0200

> vhost checked the counter within the refcnt before decrementing.  It
> really wanted to know that it is the one that has the last reference, as
> a way to batch freeing resources a bit more efficiently.
> 
> Note: we only let refcount go to 0 on device release.
> 
> This works well but we now access the ref counter twice so there's a
> race: all users might see a high count and decide to defer freeing
> resources.
> In the end no one initiates freeing resources until the last reference
> is gone (which is on VM shotdown so might happen after a looooong time).
> 
> Let's do what we probably should have done straight away:
> switch from kref to plain atomic, documenting the
> semantics, return the refcount value atomically after decrement,
> then use that to avoid the deadlock.
> 
> Reported-by: Qin Chuanyu <qinchuanyu@huawei.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
> 
> This patch is needed for 3.14 and -stable.

Applied and queued up for -stable.
