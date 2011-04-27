From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Applying inappropriate ioctl operation on socket
 should return ENOTTY
Date: Wed, 27 Apr 2011 08:55:09 +0200
Message-ID: <1303887309.2699.58.camel@edumazet-laptop>
References: <1303882625-28115-1-git-send-email-lifongsun@gmail.com>
	 <1303883910.2699.53.camel@edumazet-laptop>
	 <20110427063730.GA20313@md5.ntu.edu.sg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Lifeng Sun <lifongsun@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110427063730.GA20313@md5.ntu.edu.sg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 27 avril 2011 =C3=A0 14:37 +0800, Lifeng Sun a =C3=A9crit :
> On 07:58 Wed 04/27/11 Apr, Eric Dumazet wrote:
> > Really ?
> >=20
> > EINVAL is ok too : Request or argp is not valid.
>=20
> I'm afraid not. SUSv4 specifies, say,
>=20
>   int tcsetattr(int fildes, int optional_actions,
>          const struct termios *termios_p);
>=20
>  ERROR:
>   [EINVAL]
>       The optional_actions argument is not a supported value, or an
>       attempt was made to change an attribute represented in the
>       termios structure to an unsupported value.
>=20
>   [ENOTTY]
>       The file associated with fildes is not a terminal.
>=20
> which means when we apply tcsetattr (implemented by ioctl) to _any_
> non-terminal file descriptor, it should set errno to ENOTTY rather
> than EINVAL.

Thats not so simple. This is a known and documented artifact.

In old days, ioctl() had a meaning for TTYS (mostly).



man isatty

ERRORS
       EBADF  fd is not a valid file descriptor.

       EINVAL fd refers to a file other than a terminal.  POSIX.1-2001 =
specifies the error ENOTTY for this case.


This is not because POSIX changes rules that we must change kernel and =
break applications.

Conformant applications use isatty(fd) and test result code being 1 or =
not 1

This way, they work with linux 1.0, 2.0, 2.2, 2.4, .... and other OSes =
as well.
