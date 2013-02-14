From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH 1/1] VSOCK: Introduce VM Sockets
Date: Thu, 14 Feb 2013 15:18:02 -0500
Message-ID: <CA+1xoqfWGUuFjruFk1UV1BAXwzZvX4_i0MShQEpsq69B6P9ieg@mail.gmail.com>
References: <1360196636-9357-1-git-send-email-acking@vmware.com>
	<1360196636-9357-2-git-send-email-acking@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: Andy King <acking@vmware.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1360196636-9357-2-git-send-email-acking@vmware.com>
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

Hi Andy,

On Wed, Feb 6, 2013 at 7:23 PM, Andy King <acking@vmware.com> wrote:
> + * Specifically, we initialize the vsock_bind_table array to a size of
> + * VSOCK_HASH_SIZE + 1 so that vsock_bind_table[0] through
> + * vsock_bind_table[VSOCK_HASH_SIZE - 1] are for bound sockets and
> + * vsock_bind_table[VSOCK_HASH_SIZE] is for unbound sockets.  The hash function
> + * mods with VSOCK_HASH_SIZE - 1 to ensure this.
> + */
> +#define VSOCK_HASH_SIZE         251
> +#define MAX_PORT_RETRIES        24
> +
> +#define VSOCK_HASH(addr)        ((addr)->svm_port % (VSOCK_HASH_SIZE - 1))
> +#define vsock_bound_sockets(addr) (&vsock_bind_table[VSOCK_HASH(addr)])
> +#define vsock_unbound_sockets     (&vsock_bind_table[VSOCK_HASH_SIZE])
> +
> +/* XXX This can probably be implemented in a better way. */
> +#define VSOCK_CONN_HASH(src, dst)                              \
> +       (((src)->svm_cid ^ (dst)->svm_port) % (VSOCK_HASH_SIZE - 1))
> +#define vsock_connected_sockets(src, dst)              \
> +       (&vsock_connected_table[VSOCK_CONN_HASH(src, dst)])
> +#define vsock_connected_sockets_vsk(vsk)                               \
> +       vsock_connected_sockets(&(vsk)->remote_addr, &(vsk)->local_addr)
> +
> +static struct list_head vsock_bind_table[VSOCK_HASH_SIZE + 1];
> +static struct list_head vsock_connected_table[VSOCK_HASH_SIZE];
> +static DEFINE_SPINLOCK(vsock_table_lock);

Why isn't it using the kernel's linux/hashtable.h?


Thanks,
Sasha
