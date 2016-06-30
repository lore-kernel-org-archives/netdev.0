From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: It's back! (Re: [REGRESSION] NFS is creating a hidden port
 (left over from xs_bind() ))
Date: Thu, 30 Jun 2016 16:07:26 -0400
Message-ID: <20160630160726.304a3d14@gandalf.local.home>
References: <20160630085950.61e5c7e0@gandalf.local.home>
	<C44AFFBB-EF40-4B22-8B45-7817EB7276E3@primarydata.com>
	<20160630112341.5ab5a821@gandalf.local.home>
	<72EF2259-3A78-4FE3-8E0E-B3090FDFF14F@primarydata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Schumaker Anna <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"Linux NFS Mailing List" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Linux Network Devel Mailing List" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Fields Bruce <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
To: Trond Myklebust <trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <72EF2259-3A78-4FE3-8E0E-B3090FDFF14F-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Jun 2016 18:30:42 +0000
Trond Myklebust <trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org> wrote:


> Wait. So the NFS mount is still active, it=E2=80=99s just that the so=
cket
> disconnected due to no traffic? That should be OK. Granted that the
> port can=E2=80=99t be reused by another process, but you really don=E2=
=80=99t want
> that: what if there are no other ports available and you start
> writing to a file on the NFS partition?

What would cause the port to be connected to a socket again? I copied a
large file to the nfs mount, and the hidden port is still there?

Remember, this wasn't always the case, the hidden port is a recent
issue.

I ran wireshark on this and it appears to create two ports for NFS. One
of them is canceled by the client (sends a FIN/ACK) and this port is
what lays around never to be used again, and uses the other port for
all connections after that.

When I unmount the NFS directory, the port is finally freed (but has no
socket attached to it). What is the purpose of keeping this port around=
?

I can reproduce this by having the client unmount and remount the
directory.

-- Steve
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
