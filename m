From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] virtio-net: correctly delete napi hash
Date: Thu, 12 Mar 2015 14:37:49 -0400 (EDT)
Message-ID: <20150312.143749.1356539359045388378.davem@davemloft.net>
References: <1426139864-25023-1-git-send-email-jasowang@redhat.com>
	<20150312082351-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20150312082351-mutt-send-email-mst@redhat.com>
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
Date: Thu, 12 Mar 2015 08:25:34 +0100

> On Thu, Mar 12, 2015 at 01:57:44PM +0800, Jason Wang wrote:
>> We don't delete napi from hash list during module exit. This will
>> cause the following panic when doing module load and unload:
 ...
>> This patch fixes this by doing this in virtnet_free_queues(). And also
>> don't delete napi in virtnet_freeze() since it will call
>> virtnet_free_queues() which has already did this.
>> 
>> Fixes 91815639d880 ("virtio-net: rx busy polling support")
>> Cc: Rusty Russell <rusty@rustcorp.com.au>
>> Cc: Michael S. Tsirkin <mst@redhat.com>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
 ...
> Dave, can you pick this up pls?
> Looks like a stable candidate too.

Applied and queued up for -stable, thanks.
