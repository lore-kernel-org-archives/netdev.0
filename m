From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [6/9][PATCH 2.6] Fix Tx engine race for good
Date: Sat, 19 Jun 2004 17:22:44 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D4AEA4.6050005@pobox.com>
References: <20040615174933.GA11294@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Roger Luethi <rl@hellgate.ch>
In-Reply-To: <20040615174933.GA11294@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Roger Luethi wrote:
> +#define RHINE_WAIT_FOR(condition) do {					\
> +	int i=1024;							\
> +	while (!(condition) && --i)					\
> +		;							\
> +	if (debug > 1 && i < 512)					\
> +		printk(KERN_INFO "%s: %4d cycles used @ %s:%d\n",	\
> +				DRV_NAME, 1024-i, __func__, __LINE__);	\
> +} while(0)

empty loops need at least a cpu_relax(), if not a true delay to 
guarantee the timing you desire.

Also, it would be nice to change the name, since there isn't anything 
rhine-specific about this macro.

	Jeff
