From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [RFC] Introduce to batch variants of accept() and epoll_ctl() syscall
Date: Fri, 15 Jun 2012 12:29:45 +0800
Message-ID: <CABa6K_H3NrvvZ3Bh7JqsR6h33BSqYPBenUDG5Yt1U=2VvP700g@mail.gmail.com>
References: <4FDAB652.6070201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	davidel@xmailserver.org
To: Li Yu <raise.sail@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FDAB652.6070201@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 15, 2012 at 12:13 PM, Li Yu <raise.sail@gmail.com> wrote:
> Hi,
>
> =A0We encounter a performance problem in a large scale computer
> cluster, which needs to handle a lot of incoming concurrent TCP
> connection requests.
>
> =A0The top shows the kernel is most cpu hog, the testing is simple,
> just a accept() -> epoll_ctl(ADD) loop, the ratio of cpu util sys% to
> si% is about 2:5.
>
> =A0I also asked some experienced webserver/proxy developers in my tea=
m
> for suggestions, it seem that behavior of many userland programs alre=
ady
> called accept() multiple times after it is waked up by
> epoll_wait(). And the common action is adding the fd that accept()
> return into epoll interface by epoll_ctl() syscall then.
>
> =A0Therefore, I think that we'd better to introduce to batch variants=
 of
> accept() and epoll_ctl() syscall, just like sendmmsg() or recvmmsg().
>
> =A0For accept(), we may need a new syscall, it may like this,
>
> =A0struct accept_result {
> =A0 =A0 =A0int fd;
> =A0 =A0 =A0struct sockaddr addr;
> =A0 =A0 =A0socklen_t addr_len;
> =A0};
>
> =A0int maccept4(int fd, int flags, int nr_accept_result, struct
> accept_result *results);
>
> =A0For epoll_ctl(), there are two means to extend it, I prefer to ext=
end
> current interface instead of introduce to new syscall. We may introdu=
ce
> to a new flag EPOLL_CTL_BATCH. If userland call epoll_ctl() with this
> flag set, the meaning of last two arguments of epoll_ctl() change, .e=
=2Eg:
>
> =A0struct batch_epoll_event batch_event[] =3D {
> =A0 =A0 =A0 =A0 {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0.fd =3D a_newsock_fd;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0.epoll_event =3D { ... };
> =A0 =A0 =A0 =A0 },
> =A0 =A0 =A0 =A0 ...
> =A0};
>
> =A0ret =3D epoll_ctl(fd, EPOLL_CTL_ADD|EPOLL_CTL_BATCH, nr_batch_even=
ts,
> batch_events);
>

I think it is good idea. Would you please implement a prototype and
give some numbers? This kind of data may help selling this idea.
Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
