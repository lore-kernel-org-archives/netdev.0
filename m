From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when
	using SELinux and SOCK_SEQPACKET
Date: Thu, 18 Nov 2004 16:58:07 +0000
Message-ID: <1100797066.6019.20.camel@localhost.localdomain>
References: <Xine.LNX.4.44.0411181219590.5236-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@osdl.org>,
        Ross Kendall Axe <ross.axe@blueyonder.co.uk>, netdev@oss.sgi.com,
        Stephen Smalley <sds@epoch.ncsc.mil>,
        lkml <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0411181219590.5236-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Iau, 2004-11-18 at 17:25, James Morris wrote:
> 1) Don't call security_unix_may_send() hook during sendmsg() for 
> SOCK_SEQPACKET, and ensure that sendmsg() can only be called on a 
> connected socket so as not to bypass the security_unix_stream_connect() 
> hook.
> 
> 2) Return -EINVAL if sendto() is called on SOCK_SEQPACKET with an address 
> supplied.

Consider shutdown(). A sendmsg into shutdown must return the pending
ECONNRESET
first. 
