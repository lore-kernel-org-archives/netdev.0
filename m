From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch] Convert sockets_in_use to use per_cpu areas
Date: Mon, 23 Dec 2002 12:16:32 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021223.121632.105420794.davem@redhat.com>
References: <20021223190847.G23413@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kiran@in.ibm.com
In-Reply-To: <20021223190847.G23413@in.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ravikiran G Thirumalai <kiran@in.ibm.com>
   Date: Mon, 23 Dec 2002 19:08:48 +0530

    
   -static union {
   -	int	counter;
   -	char	__pad[SMP_CACHE_BYTES];
   -} sockets_in_use[NR_CPUS] __cacheline_aligned = {{0}};
   +static DEFINE_PER_CPU(int, sockets_in_use);

You have to provide an explicit initializer for DEFINE_PER_CPU
declarations or you break some platforms with older GCC's which
otherwise won't put it into the proper section.
