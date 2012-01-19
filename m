From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/5] ring_buffer: Export for_each_buffer_cpu()
Date: Wed, 18 Jan 2012 20:18:43 -0500
Message-ID: <1326935923.17534.94.camel@gandalf.stny.rr.com>
References: <1326926610-17830-1-git-send-email-rw@linutronix.de>
	 <1326926610-17830-2-git-send-email-rw@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Richard Weinberger <richard@nod.at>
To: Richard Weinberger <rw@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1326926610-17830-2-git-send-email-rw@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-01-18 at 23:43 +0100, Richard Weinberger wrote:
> From: Richard Weinberger <richard@nod.at>
> 

Missing change log.


Otherwise,

Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve

> 
> Signed-off-by: Richard Weinberger <richard@nod.at>
> ---
>  include/linux/ring_buffer.h |    5 +++++
>  kernel/trace/ring_buffer.c  |    7 +++++++
>  2 files changed, 12 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ring_buffer.h b/include/linux/ring_buffer.h
> index 67be037..5c1c29f 100644
> --- a/include/linux/ring_buffer.h
> +++ b/include/linux/ring_buffer.h
> @@ -185,4 +185,9 @@ enum ring_buffer_flags {
>  	RB_FL_OVERWRITE		= 1 << 0,
>  };
>  
> +cpumask_var_t *ring_buffer_mask(struct ring_buffer *buffer);
> +
> +#define for_each_buffer_cpu(buffer, cpu) \
> +	for_each_cpu(cpu, *(ring_buffer_mask(buffer)))
> +
>  #endif /* _LINUX_RING_BUFFER_H */
> diff --git a/kernel/trace/ring_buffer.c b/kernel/trace/ring_buffer.c
> index f5b7b5c..a4117c5 100644
> --- a/kernel/trace/ring_buffer.c
> +++ b/kernel/trace/ring_buffer.c
> @@ -348,6 +348,7 @@ void *ring_buffer_event_data(struct ring_buffer_event *event)
>  }
>  EXPORT_SYMBOL_GPL(ring_buffer_event_data);
>  
> +#undef for_each_buffer_cpu
>  #define for_each_buffer_cpu(buffer, cpu)		\
>  	for_each_cpu(cpu, buffer->cpumask)
>  
> @@ -4139,3 +4140,9 @@ static int rb_cpu_notify(struct notifier_block *self,
>  	return NOTIFY_OK;
>  }
>  #endif
> +
> +cpumask_var_t *ring_buffer_mask(struct ring_buffer *buffer)
> +{
> +	return &buffer->cpumask;
> +}
> +EXPORT_SYMBOL_GPL(ring_buffer_mask);
