From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v2 net-next 0/3] bpf: share helpers between tracing and
 networking
Date: Tue, 16 Jun 2015 10:10:56 -0700
Message-ID: <558058A0.7030201@plumgrid.com>
References: <1434163154-5218-1-git-send-email-ast@plumgrid.com> <20150615.160130.583783771772303463.davem@davemloft.net> <557F97F3.6060400@plumgrid.com> <557FEA2C.5080408@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org,
	wangnan0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <557FEA2C.5080408-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 6/16/15 2:19 AM, Daniel Borkmann wrote:
> if you really want to, you
> could go via skb->sk->sk_socket->file and then retrieve credentials
> from there for egress side (you can have a look at xt_owner). You'd
> need a different *_proto helper for tc in that case, which would
> then map to BPF_FUNC_get_current_uid_gid, etc. But that doesn't work
> for ingress however, even if you would have early demux, so you
> would need to let the eBPF helper function return an error code in
> that case.

was looking at cls_flow to do exactly that, but with different helper
name. Like bpf_get_socket_uid_gid(). The use case is to collect
network statistics per-user and per-process. I think android still using
some out of tree hacks for that. Ingress indeed is not solved by this
skb->sk->sk_socket approach. I considered kprobe style, but accessing
skb->len via probe_read is kernel specific, nonportable and slow-ish.
Ideally we would allow a blend of tracing and networking programs,
then the best solution would be one or two stable tracepoints in
networking stack where skb is visible and receiving/transmitting task
is also visible, then skb->len and task->pid together would give nice
foundation for accurate stats.
