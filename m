From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] virtio-net: rx busy polling support
Date: Tue, 15 Jul 2014 12:21:43 +0200
Message-ID: <1405419703.10255.26.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1405417265-13103-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1405417265-13103-1-git-send-email-jasowang@redhat.com>
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

On Tue, 2014-07-15 at 17:41 +0800, Jason Wang wrote:
> Add basic support for rx busy polling.
> 
> 1 byte netperf tcp_rr on mlx4 shows 116% improvement: the transaction
> rate was increased from 9151.94 to 19787.37.

This is a misleading changelog.

You forgot to describe how you allowed busy polling, as it is not
'automatic'

If not, this patch adds two spinlock/unlock pairs in fast path.

Also, it looks like you could split this in smaller patches.

virtnet_napi_disable_all() & virtnet_napi_enable_all() could be added in
a separate patch for example.
