From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH] Allow TCP connections to cache SYN packet for userspace inspection
Date: Fri, 1 May 2015 12:27:42 -0700
Message-ID: <CALCETrWi6h3DRu6Z8jJ_-MiWqRRyKZHntpJFNON=GpAjMDYXmQ@mail.gmail.com>
References: <1430502237-5619-1-git-send-email-emunson@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric B Munson <emunson-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1430502237-5619-1-git-send-email-emunson-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, May 1, 2015 at 10:43 AM, Eric B Munson <emunson-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org> wrote:
> In order to enable policy decisions in userspace, the data contained in
> the SYN packet would be useful for tracking or identifying connections.
> Only parts of this data are available to userspace after the hand shake
> is completed.  This patch exposes a new setsockopt() option that will,
> when used with a listening socket, ask the kernel to cache the skb
> holding the SYN packet for retrieval later.  The SYN skbs will not be
> saved while the kernel is in syn cookie mode.
>
> The same option will ask the kernel for the packet headers when used
> with getsockopt() with the socket returned from accept().  The cached
> packet will only be available for the first getsockopt() call, the skb
> is consumed after the requested data is copied to userspace.  Subsequent
> calls will return -ENOENT.  Because of this behavior, getsockopt() will
> return -E2BIG if the caller supplied a buffer that is too small to hold
> the skb header.

What's the purpose and what headers are you returning?

There was a bit of a mixup with tx timestamps where the set of headers
returned was possibly excessive and incompletely thought out the first
time around.

--Andy
