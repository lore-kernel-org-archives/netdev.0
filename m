From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC Patch] net: reserve ports for applications using fixed
 port numbers
Date: Thu, 04 Feb 2010 13:56:39 -0800 (PST)
Message-ID: <20100204.135639.69720709.davem@davemloft.net>
References: <20100204.094110.64247447.davem@davemloft.net>
	<201002042015.51092.opurdila@ixiacom.com>
	<201002050645.CEC95380.MLOtOVFFHSFOQJ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: opurdila-+zzKsuq53OdBDgjK7y7TUQ@public.gmane.org, amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201002050645.CEC95380.MLOtOVFFHSFOQJ-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
Date: Fri, 5 Feb 2010 06:45:28 +0900

> Octavian Purdila wrote:
>> 
>> int inet_is_reserved_local_port(int port)
>> {
>> 	if (test_bit(port, reserved_ports))
>> 		return 1;
>> 	return 0;
>> }
>> 
> Above check is exactly what I'm doing in the LSM hook.

But his version can be done inline in 2 or 3 instructions.

An LSM hook will result in an indirect function call,
all live registers spilled to the stack, then all of
those reloaded when the function returns.

It will be much more expensive.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
