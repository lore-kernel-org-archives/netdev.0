From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: 32 bit (socket layer) ioctl emulation for 64 bit kernels- Question regarding...
Date: Mon, 10 Oct 2005 13:48:48 +0200
Message-ID: <200510101348.49598.arnd@arndb.de>
References: <3ad486780510092121h78a522cat11f33581dfc670dc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750759AbVJJLrf@vger.kernel.org>
To: spereira <pereira.shaun@gmail.com>
In-Reply-To: <3ad486780510092121h78a522cat11f33581dfc670dc@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Maandag 10 Oktober 2005 06:21, spereira wrote:
>
> Is there currently an alternative to register_ioctl32_conversion that
> would help achive 32 bit ioctl emulation at the socket layer?
> Any suggestions/advice whould be much appreciated.

The correct solution would be to add the missing functionality to
net/socket.c and move over the implementation of SIOC* from
fs/compat_ioctl.c. Getting the code path right is a little tricky,
but I think a patch to fix this up would be appreciated.

As a start, you could define a compat_sock_ioctl along the
lines of compat_blkdev_ioctl and add your own handlers to the
x25_proto_ops, but IMHO it would makes sense to get rid of stuff
like dev_ifsioc from fs/compat_ioctl.c at the same time by
introducing a new compat_dev_ioctl called from compat_sock_ioctl.

	Arnd <><
