From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH 1/2] remove all uses of printf's %n
Date: Fri, 20 Sep 2013 10:08:08 +0200
Message-ID: <523C0268.20404@suse.cz>
References: <CAGXu5jL+NeBw2_vXymM81UdtS6UO7KZA2S4rf3gwM_7nSJ2h6g@mail.gmail.com>	<20130917205742.16147.qmail@science.horizon.com>	<201309191756.BCF65661.MQFOLSJOFHFtOV@I-love.SAKURA.ne.jp>	<CAGXu5jK_D1BJOQr=1A-UFrpM5Ad+Qu894HT_XjkZh4EmsbCkTQ@mail.gmail.com> <201309201309.GFB52620.OQOtSFLMJVHOFF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: keescook@chromium.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	linux@horizon.com, akpm@linux-foundation.org,
	dan.carpenter@oracle.com, geert@linux-m68k.org, JBeulich@suse.com,
	joe@perches.com, kosaki.motohiro@gmail.com
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	viro@zeniv.linux.org.uk, xemul@openvz.org,
	remi.denis-courmont@nokia.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201309201309.GFB52620.OQOtSFLMJVHOFF@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/20/2013 06:09 AM, Tetsuo Handa wrote:
> --- a/fs/proc/consoles.c
> +++ b/fs/proc/consoles.c
...
> @@ -47,11 +46,10 @@ static int show_console_dev(struct seq_file *m, void *v)
>  			con_flags[a].name : ' ';
>  	flags[a] = 0;
>  
> -	seq_printf(m, "%s%d%n", con->name, con->index, &len);
> -	len = 21 - len;
> -	if (len < 1)
> -		len = 1;
> -	seq_printf(m, "%*c%c%c%c (%s)", len, ' ', con->read ? 'R' : '-',
> +	seq_setwidth(m, 21 - 1);
> +	seq_printf(m, "%s%d", con->name, con->index);
> +	seq_pad(m, ' ');
> +	seq_printf(m, "%c%c%c (%s)", con->read ? 'R' : '-',
>  			con->write ? 'W' : '-', con->unblank ? 'U' : '-',
>  			flags);

Hello, do you really need seq_setwidth? It makes it really ugly...

Or do we need that all? Couldn't we simply have seq_printf_padded? Or
maybe some % modifier in seq_printf to pad the string?

> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
...
> @@ -2548,15 +2549,15 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
>  					 (fi->fib_advmss ?
>  					  fi->fib_advmss + 40 : 0),
>  					 fi->fib_window,
> -					 fi->fib_rtt >> 3, &len);
> +					 fi->fib_rtt >> 3);
>  			else
>  				seq_printf(seq,
>  					 "*\t%08X\t%08X\t%04X\t%d\t%u\t"
> -					 "%d\t%08X\t%d\t%u\t%u%n",
> +					 "%d\t%08X\t%d\t%u\t%u",
>  					 prefix, 0, flags, 0, 0, 0,
> -					 mask, 0, 0, 0, &len);
> +					 mask, 0, 0, 0);
>  
> -			seq_printf(seq, "%*s\n", 127 - len, "");
> +			seq_pad(seq, '\n');

Hmm, seq_pad is unintuitive. I would say it pads the string by '\n'. Of
course it does not, but...

thanks,
-- 
js
suse labs
