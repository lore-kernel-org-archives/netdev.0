From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/9] net: openvswitch: use this_cpu_ptr
	per-cpu helper
Date: Thu, 1 Nov 2012 14:33:45 +0000
Message-ID: <0000013abc646055-30441bd6-241f-436a-a356-9cd462da66ce-000000@email.amazonses.com>
References: <50910A04.5000003@gmail.com>
	<0000013ab7e86f8a-4adb8b81-19be-4264-96f1-924aaf3819f2-000000@email.amazonses.com>
	<509249C7.3080000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel-Maillist <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Shan Wei <shanwei88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <509249C7.3080000-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 1 Nov 2012, Shan Wei wrote:

> But for different field in same per-cpu variable, how to guarantee n_missed
> and n_hit are from same cpu?
> this_cpu_read(dp->stats_percpu->n_missed);
> [processor changed]
> this_cpu_read(dp->stats_percpu->n_hit);

What does current guarantee that? If it is guaranteed then you can use the
__this_cpu_xxx ops.

> In addition, following usage of per_cpu_ptr can be replaced by this_cpu_read.
>
> cpu=get_cpu()
> ....
> *per_cpu_ptr(p,cpu)
> ....
> ....
> put_cpu()

Right.
