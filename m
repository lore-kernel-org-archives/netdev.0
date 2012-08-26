From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [REVIEW][PATCH 11/15] userns: Teach trace to use from_kuid
Date: Sat, 25 Aug 2012 20:18:36 -0400
Message-ID: <1345940316.19381.1.camel@pippen.local.home>
References: <87lih2h6i4.fsf@xmission.com>  <87wr0mecxz.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <87wr0mecxz.fsf@xmission.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2012-08-25 at 17:04 -0700, Eric W. Biederman wrote:
> - When tracing capture the kuid.
> - When displaying the data to user space convert the kuid into the
>   user namespace of the process that opened the report file.
> 

> index 5c38c81..c9ace83 100644
> --- a/kernel/trace/trace.c
> +++ b/kernel/trace/trace.c
> @@ -2060,7 +2060,8 @@ print_trace_header(struct seq_file *m, struct trace_iterator *iter)
>  	seq_puts(m, "#    -----------------\n");
>  	seq_printf(m, "#    | task: %.16s-%d "
>  		   "(uid:%d nice:%ld policy:%ld rt_prio:%ld)\n",
> -		   data->comm, data->pid, data->uid, data->nice,
> +		   data->comm, data->pid,
> +		   from_kuid_munged(seq_user_ns(m), data->uid), data->nice,

This is a global id. That is, it stored whatever process triggered the
report, not the one reading it. Thus, two different readers could get a
different uid for the same task that triggered the latency?

-- Steve

>  		   data->policy, data->rt_priority);
>  	seq_puts(m, "#    -----------------\n");
>  
> diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
> index 55e1f7f..40a6f30 100644
> --- a/kernel/trace/trace.h
> +++ b/kernel/trace/trace.h
> @@ -147,7 +147,7 @@ struct trace_array_cpu {
>  	unsigned long		skipped_entries;
>  	cycle_t			preempt_timestamp;
>  	pid_t			pid;
> -	uid_t			uid;
> +	kuid_t			uid;
>  	char			comm[TASK_COMM_LEN];
>  };
>  


