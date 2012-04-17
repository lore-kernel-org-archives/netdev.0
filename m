From: "Carlos O'Donell" <carlos-v2tUB8YBRSi3e3T8WW9gsA@public.gmane.org>
Subject: Re: [patch] Fix handling of overlength pathname in AF_UNIX sun_path
Date: Tue, 17 Apr 2012 11:43:30 -0400
Message-ID: <CADZpyix5khp7ngjHsRafWbF7LvW4ZokT+GRHZ=1Uvz+TesbKQQ@mail.gmail.com>
References: <4F8D497F.8060601@gmail.com>
	<20120417105107.GA8614@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Tetsuo Handa <penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120417105107.GA8614-K+wRfnb2/UA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 17, 2012 at 6:51 AM, Willy Tarreau <w@1wt.eu> wrote:
> Hi Michael,
>
> On Tue, Apr 17, 2012 at 10:44:15PM +1200, Michael Kerrisk wrote:
> (...)
>> The accompanying patch changes unix_mkname() to ensure that a terminating
>> null byte is always located within the first 108 bytes of sun_path.
>> It does change the ABI for the former case where a pathname ran to 108
>> bytes without a null terminator: for that case, the call now fails with
>> the error -EINVAL. What are people's thoughts on applying this?
>
> My personal opinion is that (as you said), the risk of breaking existing
> apps is already fairly low, but we must not deliberately break existing
> apps. Eventhough there are currently a log, this is exactly what sysctls
> are made for. I would personally like to have a default limit to 107 chars
> + one zero, with a sysctl option to revert to current behaviour if ever it
> broke an application. In my opinion it's exactly comparable to the risk of
> breaking apps with mmap_min_addr : very low risk but must be covered by a
> workaround (sysctl).

To further the opinion that the risk is low:

The Open Solaris SUN_LEN macro uses strlen to compute the length.

The glibc SUN_LEN macro uses strlen to compute the length.

The Mac OS X libc SUN_LEN macro uses strlen to compute the length.

The linux man-pages project sets the user expectation that it is a
`null-terminated string' (circular argument).

I see every expectation from userspace/glibc that it should be 107 chars + '\0'.

Cheers,
Carlos.
