From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH AND RFC_PATCH] 1. Leak corking option in ipv4 2. ipv6
 opt panic
Date: Wed, 10 Mar 2004 14:47:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040310144758.5e0b4c7c.davem@redhat.com>
References: <Pine.LNX.4.44.0403091754440.6308-100000@linux-009047018241>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, krkumar@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <kkumar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0403091754440.6308-100000@linux-009047018241>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 9 Mar 2004 18:05:48 -0800 (PST)
Krishna Kumar <kkumar@us.ibm.com> wrote:

> Patch1 :
> --------
> I think every socket can leak memory when it allocates a cork.opt and
> calls ip_append_data()/ip_push_pending_frames(). This get released in
> ip_flush_pending_frames() which may not get called.

Looks correct, applied.

> Patch2 :
> ---------
> I am not sure about this possible bug which is the RFC part of the
> subject. In IPv6 ip6_append_data(), if it is possible to add extra ipv6
> options during multiple calls to append_data(), then the check for
> cork.opt could end up panicing the system because it is allocated
> for a smaller size of options. If this is a problem, then ipv4 might have
> a similar issue too. Note: Patch2 has a question embedded in it, I can
> send a better patch if you think the idea is right.

This is possible, but an APP trying to do this is buggy as I cannot
see any sane semantics for this.

I would rather we -EINVAL on such socket option changes if cork.opt is
non-NULL.  Could you whip up a patch for that?  Thanks.
