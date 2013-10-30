From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] virtio-net: correctly handle cpu hotplug notifier
	during resuming
Date: Tue, 29 Oct 2013 22:44:56 -0400 (EDT)
Message-ID: <20131029.224456.313230245288672803.davem@davemloft.net>
References: <1383030667-14343-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1383030667-14343-1-git-send-email-jasowang@redhat.com>
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

From: Jason Wang <jasowang@redhat.com>
Date: Tue, 29 Oct 2013 15:11:07 +0800

> commit 3ab098df35f8b98b6553edc2e40234af512ba877 (virtio-net: don't respond to
> cpu hotplug notifier if we're not ready) tries to bypass the cpu hotplug
> notifier by checking the config_enable and does nothing is it was false. So it
> need to try to hold the config_lock mutex which may happen in atomic
> environment which leads the following warnings:
 ...
> A correct fix is to unregister the hotcpu notifier during restore and register a
> new one in resume.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Tested-by: Fengguang Wu <fengguang.wu@intel.com>
> Cc: Wanlong Gao <gaowanlong@cn.fujitsu.com>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> This patch is needed for 3.8 and above.

Applied and queued up for -stable, thanks Jason.
