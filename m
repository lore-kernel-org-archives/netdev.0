From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net 3/9] virtio-net: fix page miscount during XDP
	linearizing
Date: Fri, 23 Dec 2016 07:54:15 -0800
Message-ID: <585D48A7.3040701@gmail.com>
References: <1482503852-12438-1-git-send-email-jasowang@redhat.com>
	<1482503852-12438-4-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1482503852-12438-4-git-send-email-jasowang@redhat.com>
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

On 16-12-23 06:37 AM, Jason Wang wrote:
> We don't put page during linearizing, the would cause leaking when
> xmit through XDP_TX or the packet exceeds PAGE_SIZE. Fix them by
> put page accordingly. Also decrease the number of buffers during
> linearizing to make sure caller can free buffers correctly when packet
> exceeds PAGE_SIZE. With this patch, we won't get OOM after linearize
> huge number of packets.
> 
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---

Thanks! looks good. By the way do you happen to have any actual
configuration where this path is hit? I obviously didn't test this
very long other than a quick test with my hacked vhost driver.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
