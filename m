From: "David S. Miller" <davem@redhat.com>
Subject: Re: kernel bug: control message on AF_INET6 sockets strangely
 truncated on sparc64 platform
Date: Mon, 28 Jul 2003 08:29:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030728082915.67d74b31.davem@redhat.com>
References: <20030728151849.GA18408@wsx.ksp.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jan Oravec <jan.oravec@6com.sk>
In-Reply-To: <20030728151849.GA18408@wsx.ksp.sk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Jul 2003 17:18:49 +0200
Jan Oravec <jan.oravec@6com.sk> wrote:

> while trying to setup IPv6-capable bind DNS server on UltraSparc II box,
> i have found the following problem:

Yes, this is an unfortunate consequence of how we emulate
socket CMSGs in 32-bit applications running on a 64-bit
kernel in 2.4.x

It is not easily fixable in 2.4.x, in fact it would be such
an intrusive and bug-prone change that I'm probably not going
to fix it in 2.4.x

The workaround in the app is the use slightly larger than
necessary CMSG buffers.  Sorry :(

2.5.x/2.6.x does things properly and the bug shouldn't show up
there.
