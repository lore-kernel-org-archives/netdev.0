From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 2.6.11-rc4-mm1] connector: Add a fork connector
Date: Wed, 2 Mar 2005 06:51:52 -0800
Message-ID: <20050302065152.79d9fba2.pj@sgi.com>
References: <1109240677.1738.196.camel@frecb000711.frec.bull.fr>
	<1109753292.8422.117.camel@frecb000711.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, johnpol@2ka.mipt.ru,
	elsa-devel@lists.sourceforge.net, jlan@engr.sgi.com, gh@us.ibm.com,
	efocht@hpce.nec.com, netdev@oss.sgi.com, kaigai@ak.jp.nec.com
To: Guillaume Thouvenin <guillaume.thouvenin@bull.net>
In-Reply-To: <1109753292.8422.117.camel@frecb000711.frec.bull.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Guillaume wrote:
> 
>   I also run the lmbench and results are send in response to another
> thread "A common layer for Accounting packages". When fork connector is
> turned off the overhead is negligible. 

Good.

If I read this code right:
>
> +static inline void fork_connector(pid_t parent, pid_t child)
> +{
> +	static DEFINE_SPINLOCK(cn_fork_lock);
> +	static __u32 seq;   /* used to test if message is lost */
> +
> +	if (cn_fork_enable) {

then the code executed if the fork connector is off is a call to an
inline function that tests an integer, finds it zero, and returns.

This is sufficiently little code that I for one would hardly
even need lmbench to be comfortable that fork() wasn't impacted
seriously, in the case that the fork connector is disabled.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.650.933.1373, 1.925.600.0401
