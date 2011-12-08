From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC] virtio_net: fix refill related races
Date: Thu, 08 Dec 2011 15:07:29 +1030
Message-ID: <8739cvisqe.fsf@rustcorp.com.au>
References: <20111207152120.GA23417@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>, Amit Shah <amit.shah@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20111207152120.GA23417@redhat.com>
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

On Wed, 7 Dec 2011 17:21:22 +0200, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> Fix theoretical races related to refill work:
> 1. After napi is disabled by ndo_stop, refill work
>    can run and re-enable it.
> 2. Refill can reschedule itself, if this happens
>    it can run after cancel_delayed_work_sync,
>    and will access device after it is destroyed.
> 
> As a solution, add flags to track napi state and
> to disable refill, and toggle them on start, stop
> and remove; check these flags on refill.

Why isn't a "dont-readd" flag sufficient?

Cheers,
Rusty.
