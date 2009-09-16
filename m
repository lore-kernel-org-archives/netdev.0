From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: fanotify as syscalls
Date: Wed, 16 Sep 2009 13:30:26 +0200
Message-ID: <200909161330.26815.arnd@arndb.de>
References: <20090911.114620.260824240.davem@davemloft.net> <20090915201620.GB32192@ioremap.net> <1253051699.5213.18.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	Jamie Lokier <jamie@shareable.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org,
	torvalds@linux-foundation.org
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1253051699.5213.18.camel@dhcp231-106.rdu.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 15 September 2009, Eric Paris wrote:
> fanotify_modify_mark_at() --- like inotify_add_watch and rm_watch
> fanotify_modify_mark_fd() --- same but with an fd instead of a path

I think these two can be merged into one without adding complexity,
in the same way that sys_utimensat can take a file descriptor or
a path or both.

> fanotify_response() --- userspace tells the kernel what to do if requested/allowed
>    (could probably be done using write() to the fanotify fd)
> fanotify_exclude() --- a horrid syscall which might be better as an ioctl since it isn't strongly typed....

Please don't use an ioctl here. While ioctl is fine for character devices
and sort of fine for sockets, I think it would be very bad style to use
it on file descriptors that you get back from specialized syscalls like
fanotify_init. Do one or the other, but do it consistently.

Why is it not strongly typed anyway? Something like

int fanotify_ignore_sb(int fanotify_fd, unsigned int flag,
                       long f_type, fsid_t f_fsid);

would be type safe, although I think it would be better to only handle
one of the two cases. Can you think of a case that you can't handle if
you have to decide between them and only do one interface (f_type or fsid)?

	Arnd <><
