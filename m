From: Willy Tarreau <w@1wt.eu>
Subject: Re: [patch] Fix handling of overlength pathname in AF_UNIX sun_path
Date: Tue, 17 Apr 2012 12:51:07 +0200
Message-ID: <20120417105107.GA8614@1wt.eu>
References: <4F8D497F.8060601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Tetsuo Handa <penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
To: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4F8D497F.8060601-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Michael,

On Tue, Apr 17, 2012 at 10:44:15PM +1200, Michael Kerrisk wrote:
(...)
> The accompanying patch changes unix_mkname() to ensure that a terminating 
> null byte is always located within the first 108 bytes of sun_path. 
> It does change the ABI for the former case where a pathname ran to 108
> bytes without a null terminator: for that case, the call now fails with
> the error -EINVAL. What are people's thoughts on applying this?

My personal opinion is that (as you said), the risk of breaking existing
apps is already fairly low, but we must not deliberately break existing
apps. Eventhough there are currently a log, this is exactly what sysctls
are made for. I would personally like to have a default limit to 107 chars 
+ one zero, with a sysctl option to revert to current behaviour if ever it
broke an application. In my opinion it's exactly comparable to the risk of
breaking apps with mmap_min_addr : very low risk but must be covered by a
workaround (sysctl).

Just my 2 cents,
Willy
