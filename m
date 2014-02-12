From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2 5/6] vhost_net: poll vhost queue after marking DMA is
	done
Date: Wed, 12 Feb 2014 18:01:17 +0200
Message-ID: <20140212160117.GA25440@redhat.com>
References: <1377836962-49780-1-git-send-email-jasowang@redhat.com>
	<1377836962-49780-6-git-send-email-jasowang@redhat.com>
	<52FB24EA.3060001@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Qin Chuanyu <qinchuanyu@huawei.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <52FB24EA.3060001@huawei.com>
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

On Wed, Feb 12, 2014 at 03:38:18PM +0800, Qin Chuanyu wrote:
> another question is that vhost_zerocopy_callback is called by kfree_skb,
> it may called in different thread context.
> vhost_poll_queue is called decided by ubufs->kref.refcount, this may
> cause there isn't any thread call  vhost_poll_queue, but at least
> one is needed. and this cause network break.
> We could repeat it by using 8 netperf thread in guest to xmit tcp to
> its host.

Thanks a lot for the report, will send the patch soon.

> 
> I think if using atomic_read to decide while do vhost_poll_queue or not,
> at least a spink_lock is needed.

No, nothing so drastic.
