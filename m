From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] Check for SOL_SOCKET in compat_sys_getsockopt
Date: Fri, 07 Jan 2005 10:35:29 +0000
Message-ID: <1105094129.5547.98.camel@baythorne.infradead.org>
References: <20050103143306.GG25446@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050103143306.GG25446@suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-03 at 15:33 +0100, Olaf Kirch wrote:
> compat_sys_getsockopt checks for SO_RCVTIMEO/SO_SNDTIMEO without
> making sure that the level is actually SOL_SOCKET. This can break
> getsockopt() requests for other protocols.

It's a band-aid, not a fix. Trying to do the conversion in
compat_sys_getsockopt() for _all_ possible sockopts is broken.

I think we need to let each protocol offer compat [gs]etsockopt()
methods of its own, or at least have the existing [gs]etsockopt()
methods check whether the current process is 32-bit or 64-bit and do the
right thing.

Have you started looking at netfilter with 32-bit userspace yet? :)

-- 
dwmw2
