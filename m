From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Bug in 2.6.10
Date: Fri, 28 Jan 2005 11:42:51 -0800
Message-ID: <20050128114251.64e0fff4@dxpl.pdx.osdl.net>
References: <41FA9239.4010401@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christian Schmid <webmaster@rapidforum.com>
In-Reply-To: <41FA9239.4010401@rapidforum.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 Jan 2005 20:27:53 +0100
Christian Schmid <webmaster@rapidforum.com> wrote:

> Hello.
> 
> In 2.6.10 there has been a "bug" introduced. You may also call it a feature, but its a crappy 
> feature for big servers. It seems the kernel is dynamically adjusting the buffer-space available for 
> sockets. Even if send-buffer has been set to 1024 KB, the kernel blocks at less if there are enough 
> sockets in use. If you have 10 sockets with 1024 KB each, they do not block at all, using full 1024 
> KB. If you have 4000 sockets, they only use 200 KB. So it seems its blocking at 800 MB. This is 
> good, if you have a 1/3 system, because else the kernel would run out of low mem. But I have a 2/2 
> system and I need them for buffers. So what can I do? Where can I adjust the "pool"?

You can set the upper bound by setting tcp_wmem. There are three values
all documented in Documentation/networking/ip-sysctl.txt

tcp_wmem - vector of 3 INTEGERs: min, default, max
	min: Amount of memory reserved for send buffers for TCP socket.
	Each TCP socket has rights to use it due to fact of its birth.
	Default: 4K

	default: Amount of memory allowed for send buffers for TCP socket
	by default. This value overrides net.core.wmem_default used
	by other protocols, it is usually lower than net.core.wmem_default.
	Default: 16K

	max: Maximal amount of memory allowed for automatically selected
	send buffers for TCP socket. This value does not override
	net.core.wmem_max, "static" selection via SO_SNDBUF does not use this.
	Default: 128K

If you want performance on big servers you are going to need lots of memory, this is
just a fact of bandwidth delay product * number of connections.

-- 
Stephen Hemminger	<shemminger@osdl.org>
