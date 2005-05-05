From: "David S. Miller" <davem@davemloft.net>
Subject: Re: e1000 (?) jumbo frames performance issue
Date: Thu, 5 May 2005 14:33:18 -0700
Message-ID: <20050505143318.004566a9.davem@davemloft.net>
References: <200505051928.32496.m.iatrou@freemail.gr>
	<427A7F5B.8050704@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: m.iatrou@freemail.gr, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <427A7F5B.8050704@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 05 May 2005 13:17:31 -0700
Rick Jones <rick.jones2@hp.com> wrote:

> I seem to recall that some of the stack defaults for SO_SNDBUF (IIRC) would 
> result in netperf sending 16KB at a time into the connection - once you sent the 
> MTU above 16K you may have started running into issues with Nagle and delayed 
> ACK?  You could try some tests adding a test-specific -D to disable Nagle, or -C 
> to set TCP_CORK, or use -m to set the send size to say, 32KB.

Yes, for one don't expect reasonable behavior if the MTU is near to or less
than the send buffer size in use.

Also, many of Nagle's notions start to fall apart at such high MTU settings.
For example, all of Nagle (even with Minshall's modifications) basically define
"small packet" as anything smaller than 1 MSS.

So something to look into (besides increasing your send buffer size with jacking
up the MTU so large) is changing Nagle to use some constant.  Perhaps something like
512 bytes or smaller, or even 128 bytes or smaller.
