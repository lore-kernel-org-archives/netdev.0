From: Alban Crequy <alban@kinvolk.io>
Subject: Re: [RFC PATCH tip/master 1/3] trace: kprobes: Show sum of probe/retprobe nmissed count
Date: Fri, 31 Mar 2017 11:45:55 +0200
Message-ID: <CADZs7q4k9YLgRuxccy7vuOns53GcPXG4D6HosRjfAeKm=RrL2A@mail.gmail.com>
References: <149076484118.24574.7083269903420611708.stgit@devbox> <149076491191.24574.9187877160820798843.stgit@devbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 	Alban Crequy <alban.crequy@gmail.com>, Alexei Starovoitov <ast@kernel.org>, 	Jonathan Corbet <corbet@lwn.net>, Arnaldo Carvalho de Melo <acme@redhat.com>, Omar Sandoval <osandov@fb.com>, 	linux-doc@vger.kernel.org, netdev@vger.kernel.org, 	linux-kernel@vger.kernel.org, =?UTF-8?Q?Iago_L=C3=B3pez_Galeiras?= <iago@kinvolk.io>, 	Michael Schubert <michael@kinvolk.io>, Dorau Lukasz <lukasz.dorau@intel.com>, systemtap@sourceware.org
To: Masami Hiramatsu <mhiramat@kernel.org>
Return-path: <systemtap-return-25255-gls-systemtap=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:systemtap-unsubscribe-gls-systemtap=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:systemtap-subscribe@sourceware.org>
List-Post: <mailto:systemtap@sourceware.org>
List-Help: <mailto:systemtap-help@sourceware.org>, <http://sourceware.org/lists.html#faqs>
Sender: systemtap-owner@sourceware.org
In-Reply-To: <149076491191.24574.9187877160820798843.stgit@devbox>
List-Id: netdev.vger.kernel.org

On Wed, Mar 29, 2017 at 7:22 AM, Masami Hiramatsu <mhiramat@kernel.org> wrote:
> Show sum of probe and retprobe nmissed count in
> kprobe_profile, since retprobe can be missed even
> if the kprobe itself succeeeded.
> This explains user why their return probe didn't hit
> sometimes.
>
> Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>

I tested this patch with my kretprobe on "inet_csk_accept" when there
are many processes waiting in the accept() syscall. I can now
successfully see the nmissed counter in
/sys/kernel/debug/tracing/kprobe_profile being incremented when the
kretprobe is missed.

Tested-by: Alban Crequy <alban@kinvolk.io>


> ---
>  kernel/trace/trace_kprobe.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
> index 013f4e7..bbdc3de 100644
> --- a/kernel/trace/trace_kprobe.c
> +++ b/kernel/trace/trace_kprobe.c
> @@ -896,7 +896,7 @@ static int probes_profile_seq_show(struct seq_file *m, void *v)
>         seq_printf(m, "  %-44s %15lu %15lu\n",
>                    trace_event_name(&tk->tp.call),
>                    trace_kprobe_nhit(tk),
> -                  tk->rp.kp.nmissed);
> +                  tk->rp.kp.nmissed + tk->rp.nmissed);
>
>         return 0;
>  }
>
