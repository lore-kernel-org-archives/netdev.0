From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH 0/2] net: connect to UNIX sockets from specified root
Date: Fri, 10 Aug 2012 11:31:25 -0700
Message-ID: <5025537D.9060300@zytor.com>
References: <20120810125701.7115.71612.stgit@localhost.localdomain> <50254FA6.3060806@zytor.com> <20120810192628.79a34d28@pyramind.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, tim.c.chen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120810192628.79a34d28-38n7/U1jhRXW96NNrWNlrekiAK3p4hvP@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/10/2012 11:26 AM, Alan Cox wrote:
>> On that whole subject...
>>
>> Do we need a Unix domain socket equivalent to openat()?
> 
> I don't think so. The name is just a file system indexing trick, it's not
> really the socket proper. It's little more than "ascii string with
> permissions attached" - indeed we also support an abstract name space
> which for a lot of uses is actually more convenient.
> 

I don't really understand why Unix domain sockets is different than any
other pathname users in this sense.  (Actually, I have never understood
why open() on a Unix domain socket doesn't give the equivalent of a
socket() + connect() -- it would make logical sense and would provide
additional functionality).

It would be different if the Unix domain sockets simply required an
absolute pathname (it is not just about the root, it is also about the
cwd, which is where the -at() functions come into play), but that is not
the case.

The abstract namespace is irrelevant for this, obviously.

> AF_UNIX between roots raises some interesting semantic questions when
> you begin passing file descriptors down them as well.

Why is that?  A file descriptor carries all that information with it...

	-hpa
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
