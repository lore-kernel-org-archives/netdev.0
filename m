From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [RFC PATCH 0/2] net: connect to UNIX sockets from specified
 root
Date: Fri, 10 Aug 2012 19:40:28 +0100
Message-ID: <20120810194028.792f29f1@pyramind.ukuu.org.uk>
References: <20120810125701.7115.71612.stgit@localhost.localdomain>
	<50254FA6.3060806@zytor.com>
	<20120810192628.79a34d28@pyramind.ukuu.org.uk>
	<5025537D.9060300@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, tim.c.chen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5025537D.9060300-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > AF_UNIX between roots raises some interesting semantic questions when
> > you begin passing file descriptors down them as well.
> 
> Why is that?  A file descriptor carries all that information with it...

Things like fchdir(). It's not a machine breaking problem but for
containers as opposed to chroot we need to be clear what the expected
isolation sematics are.

Agreed on open() for sockets.. the lack of open is a Berklix derived
pecularity of the interface. It would equally be useful to be able to
open "/dev/socket/ipv4/1.2.3.4/1135" and the like for scripts and stuff

That needs VFS changes however so you can pass the remainder of a path to
a device node. It also lets you do a lot of other sane stuff like

	open /dev/ttyS0/9600/8n1


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
