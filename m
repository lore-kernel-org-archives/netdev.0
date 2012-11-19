From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH RFC 0/5] Containerize syslog
Date: Mon, 19 Nov 2012 01:51:09 -0800
Message-ID: <874nklkjjm.fsf@xmission.com>
References: <50A9EAD8.9090501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rui Xiang <leo.ruixiang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <50A9EAD8.9090501-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Rui Xiang's message of "Mon, 19 Nov
	2012 16:16:24 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Rui Xiang <leo.ruixiang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> From: Xiang Rui <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>
> In Serge's patch (http://lwn.net/Articles/525629/), syslog_namespace was tied to a user
> namespace. We add syslog_ns tied to nsproxy instead, and implement ns_printk in
> ip_table context.
>
> We add syslog_namespace as a part of nsproxy, and a new flag CLONE_SYSLOG to unshare
> syslog area.
>
> In syslog_namespace, some necessary identifiers for handling syslog buf are contained.
> When one container creates a new syslog namespace,containerized buf will be allocated
> to store log ownned this container. Containerized identifiers such as log_first_seq
> instead of global variable only affect their own buf.The buf will not be free until
> syslog_namespace is destructed by host.
>
> Printk should be re-implimented because log buf is isolated into syslog_ns. The function
> include printk, /dev/kmsg, do_syslog and kmsg_dump should be realized in container. So,
> to make these funtions available in container, a parameter syslog_ns is necessory for
> their interfaces.
>
> For container context, the value syslog namespace is reasonable if we use current method
> to get syslog_ns when using iptable. Because the log info belong to each containers will
> be printed in host.
>
> We add a pointer in net namespace, and use it to track the syslog_ns which was created
> when the log was generated in container. Then add ns_printk to provide a new interface
> while using syslog_ns.

It occurs to me that calling this a syslog namespace is a misnomer.
Syslog in general uses unix domain sockets.  This is about the linux
kernel specific kernel log interface that tends to be put in syslog.

Are there any kernel print statements besides networking stack printks
that we want to move to show up in a new "kernel log" namespace?

For the kernel generated pieces of information that are interesting (and
their don't seem to be many of those) would we be better off using
another kernel method that is already per namespace.  Something like
netlink.

Eric
