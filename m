From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/8] ptr_ring: introduce batch dequeuing
Date: Tue, 21 Mar 2017 13:25:10 +0300
Message-ID: <9ecd2a27-4f93-2b3f-cb91-c558976973a2@cogentembedded.com>
References: <1490069087-4783-1-git-send-email-jasowang@redhat.com>
	<1490069087-4783-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1490069087-4783-2-git-send-email-jasowang@redhat.com>
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

Hello!

On 3/21/2017 7:04 AM, Jason Wang wrote:

> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  include/linux/ptr_ring.h | 65 ++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 65 insertions(+)
>
> diff --git a/include/linux/ptr_ring.h b/include/linux/ptr_ring.h
> index 6c70444..4771ded 100644
> --- a/include/linux/ptr_ring.h
> +++ b/include/linux/ptr_ring.h
> @@ -247,6 +247,22 @@ static inline void *__ptr_ring_consume(struct ptr_ring *r)
>  	return ptr;
>  }
>
> +static inline int __ptr_ring_consume_batched(struct ptr_ring *r,
> +					     void **array, int n)
> +{
> +	void *ptr;
> +	int i = 0;
> +
> +	while (i < n) {

    Hm, why not *for*?

> +		ptr = __ptr_ring_consume(r);
> +		if (!ptr)
> +			break;
> +		array[i++] = ptr;
> +	}
> +
> +	return i;
> +}
> +
>  /*
>   * Note: resize (below) nests producer lock within consumer lock, so if you
>   * call this in interrupt or BH context, you must disable interrupts/BH when
> @@ -297,6 +313,55 @@ static inline void *ptr_ring_consume_bh(struct ptr_ring *r)
[...]

MBR, Sergei
