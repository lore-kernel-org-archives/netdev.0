From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [RFC Patch] net: reserve ports for applications using fixed port numbers
Date: Fri, 05 Feb 2010 09:41:12 +0900
Message-ID: <201002050041.o150fCO8081208@www262.sakura.ne.jp>
References: <20100204.094110.64247447.davem@davemloft.net> <201002042015.51092.opurdila@ixiacom.com> <201002050645.CEC95380.MLOtOVFFHSFOQJ@I-love.SAKURA.ne.jp> <20100204.135639.69720709.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: opurdila@ixiacom.com, amwang@redhat.com,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	nhorman@tuxdriver.com, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100204.135639.69720709.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> > Octavian Purdila wrote:
> >> 
> >> int inet_is_reserved_local_port(int port)
> >> {
> >> 	if (test_bit(port, reserved_ports))
> >> 		return 1;
> >> 	return 0;
> >> }
> >> 
> > Above check is exactly what I'm doing in the LSM hook.
> 
> But his version can be done inline in 2 or 3 instructions.
> 
> An LSM hook will result in an indirect function call,
> all live registers spilled to the stack, then all of
> those reloaded when the function returns.
> 
> It will be much more expensive.

If you can accept his version, I want to use his version (with an interface for
updating above "reserved_ports" by not only root user's sysctl() but also MAC's
policy configuration).
