From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [RFC PATCH 0/2] net: connect to UNIX sockets from specified root
Date: Sat, 11 Aug 2012 10:23:22 +0400
Message-ID: <5025FA5A.4090403@parallels.com>
References: <20120810125701.7115.71612.stgit@localhost.localdomain> <50254FA6.3060806@zytor.com> <20120810192628.79a34d28@pyramind.ukuu.org.uk> <20120810191149.GA17985@fieldses.org> <20120810202818.06236f46@pyramind.ukuu.org.uk> <50259494.8060304@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org" <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	"tim.c.chen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org" <tim.c.chen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <50259494.8060304-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/11/2012 03:09 AM, H. Peter Anvin wrote:
> On 08/10/2012 12:28 PM, Alan Cox wrote:
>> Explicitly for Linux yes - this is not generally true of the AF_UNIX
>> socket domain and even the permissions aspect isn't guaranteed to be
>> supported on some BSD environments !
> 
> Yes, but let's worry about what the Linux behavior should be.
> 
>> The name is however just a proxy for the socket itself. You don't even
>> get a device node in the usual sense or the same inode in the file system
>> space.
> 
> 
> No, but it is looked up the same way any other inode is (the difference
> between FIFOs and sockets is that sockets have separate connections,
> which is also why open() on sockets would be nice.)
> 
> However, there is a fundamental difference between AF_UNIX sockets and
> open(), and that is how the pathname is delivered.  It thus would make
> more sense to provide the openat()-like information in struct
> sockaddr_un, but that may be very hard to do in a sensible way.  In that
> sense it perhaps would be cleaner to be able to do an open[at]() on the
> socket node with O_PATH (perhaps there should be an O_SOCKET option,
> even?) and pass the resulting file descriptor to bind() or connect().

I vote for this (openat + O_WHATEVER on a unix socket) as well. It will 
help us in checkpoint-restore, making handling of overmounted/unlinked
sockets much cleaner.

> 	-hpa

Thanks,
Pavel

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
