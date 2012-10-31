From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/9] net: openvswitch: use this_cpu_ptr
	per-cpu helper
Date: Wed, 31 Oct 2012 17:39:54 +0000
Message-ID: <0000013ab7e86f8a-4adb8b81-19be-4264-96f1-924aaf3819f2-000000@email.amazonses.com>
References: <50910A04.5000003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel-Maillist <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Shan Wei <shanwei88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <50910A04.5000003-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

On Wed, 31 Oct 2012, Shan Wei wrote:

> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -208,7 +208,7 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
>  	int error;
>  	int key_len;
>
> -	stats = per_cpu_ptr(dp->stats_percpu, smp_processor_id());
> +	stats = this_cpu_ptr(dp->stats_percpu);

Well this is an improvement and may be ok if the preemption is disabled at
this point. There is another possibility here to use this_cpu_read/add/inc
instead of determining the pointer to the local cpu first and then
performing operations on the fields. The pointer relocation with
this_cpu_xxx ops is implicit in the instructions and safe against changing
of processors. It would also save us the determination of a pointer to the
current cpus stats structure.
