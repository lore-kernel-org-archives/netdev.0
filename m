From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when
	using SELinux and SOCK_SEQPACKET
Date: Thu, 18 Nov 2004 23:39:32 +0000
Message-ID: <1100821144.6005.40.camel@localhost.localdomain>
References: <Xine.LNX.4.44.0411181328460.5555-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ross Kendall Axe <ross.axe@blueyonder.co.uk>, netdev@oss.sgi.com,
        Stephen Smalley <sds@epoch.ncsc.mil>,
        lkml <linux-kernel@vger.kernel.org>, Chris Wright <chrisw@osdl.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0411181328460.5555-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Iau, 2004-11-18 at 18:40, James Morris wrote:
> One thing that looks broken (unrelated to the patch I posted) is that
> unix_dgram_sendmsg() already does not check sk->sk_shutdown &
> SEND_SHUTDOWN for SOCK_SEQPACKET.

Looks like a real bug yes.

As to the other stuff I think the only change needed is to check the
queued asynchronous error and report that before going on to the
connected test
