From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/3] virtio/vringh: kill off ACCESS_ONCE()
Date: Thu, 24 Nov 2016 22:36:58 +0200
Message-ID: <20161124222357-mutt-send-email-mst@kernel.org>
References: <1479983114-17190-1-git-send-email-mark.rutland@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dave@stgolabs.net, kvm@vger.kernel.org, dbueso@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	paulmck@linux.vnet.ibm.com, dvyukov@google.com
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1479983114-17190-1-git-send-email-mark.rutland@arm.com>
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

On Thu, Nov 24, 2016 at 10:25:11AM +0000, Mark Rutland wrote:
> For several reasons, it would be beneficial to kill off ACCESS_ONCE()
> tree-wide, in favour of {READ,WRITE}_ONCE(). These work with aggregate types,
> more obviously document their intended behaviour, and are necessary for tools
> like KTSAN to work correctly (as otherwise reads and writes cannot be
> instrumented separately).
> 
> While it's possible to script the bulk of this tree-wide conversion, some cases
> such as the virtio code, require some manual intervention. This series moves
> the virtio and vringh code over to {READ,WRITE}_ONCE(), in the process fixing a
> bug in the virtio headers.
> 
> Thanks,
> Mark.

I don't have a problem with this specific patchset.

Though I really question the whole _ONCE APIs esp with
aggregate types - these seem to generate a memcpy and
an 8-byte read/writes sometimes, and I'm pretty sure this simply
can't be read/written at once on all architectures.

So I worry it's kind of like volatile in this respect,
too easy to overuse.


> Mark Rutland (3):
>   tools/virtio: fix READ_ONCE()
>   vringh: kill off ACCESS_ONCE()
>   tools/virtio: use {READ,WRITE}_ONCE() in uaccess.h
> 
>  drivers/vhost/vringh.c        | 5 +++--
>  tools/virtio/linux/compiler.h | 2 +-
>  tools/virtio/linux/uaccess.h  | 9 +++++----
>  3 files changed, 9 insertions(+), 7 deletions(-)
> 
> -- 
> 2.7.4
