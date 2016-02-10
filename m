From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 2/2] vhost: disentangle vring endianness stuff from the
	core code
Date: Wed, 10 Feb 2016 14:23:33 +0100
Message-ID: <20160210142333.744e4446.cornelia.huck@de.ibm.com>
References: <20160113170934.23705.62626.stgit@bahia.huguette.org>
	<20160113170947.23705.95216.stgit@bahia.huguette.org>
	<20160210132240-mutt-send-email-mst@redhat.com>
	<20160210140843.64ea5aa1@bahia.huguette.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Greg Kurz <gkurz@linux.vnet.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20160210140843.64ea5aa1@bahia.huguette.org>
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

On Wed, 10 Feb 2016 14:08:43 +0100
Greg Kurz <gkurz@linux.vnet.ibm.com> wrote:

> But you are right, there is a bug: we should rollback if vhost_init_used()
> fails. Something like below:
> 
>  err_used:
>         vq->private_data = oldsock;
>         vhost_net_enable_vq(n, vq);
> +       vhost_adjust_vring_endian(vq);

Shouldn't we switch back before we reenable? Or have I lost myself in
this maze here again?

>         if (ubufs)
>                 vhost_net_ubuf_put_wait_and_free(ubufs);
>  err_ubufs:
