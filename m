From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Host<->guest channel interface advice needed
Date: Wed, 26 Nov 2008 14:02:57 +0100
Message-ID: <200811261402.58033.arnd@arndb.de>
References: <20081126123919.GC3521@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gleb Natapov <gleb@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754142AbYKZNEq@vger.kernel.org>
In-Reply-To: <20081126123919.GC3521@redhat.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 26 November 2008, Gleb Natapov wrote:
> The interfaces that are being considered are netlink socket (only dat=
agram
> semantics, linux specific), new socket family or character device wit=
h
> different minor number for each channel. Which one better suits for
> the purpose? =A0Is there other kind of interface to consider? New soc=
ket
> family looks like a good choice, but it would be nice to hear other
> opinions before starting to work on it.

I think a socket and a pty both look reasonable here, but one important
aspect IMHO is that you only need a new kernel driver for the guest, if
you just use the regular pty support or Unix domain sockets in the host=
=2E

Obviously, there needs to be some control over permissions, as a guest
most not be able to just open any socket or pty of the host, so a
reasonable approach might be that the guest can only create a socket
or pty that can be opened by the host, but not vice versa. Alternativel=
y,
you create the socket/pty in host userspace and then allow passing that
down into the guest, which creates a virtio device from it.

	Arnd <><
