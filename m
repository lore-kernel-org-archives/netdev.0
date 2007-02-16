From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bug 8013] New: select for write hangs on a socket after write
 returned ECONNRESET
Date: Fri, 16 Feb 2007 10:29:14 -0800
Message-ID: <20070216102914.7d4b34f0@freekitty>
References: <20070215160405.3bd30b05@localhost.localdomain>
	<20070216152557.GA20641@2ka.mipt.ru>
	<20070216152858.GA22020@2ka.mipt.ru>
	<20070216153957.GB22020@2ka.mipt.ru>
	<20070216155450.GC22020@2ka.mipt.ru>
	<20070216161045.GA2371@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:57491 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946196AbXBPS3T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 13:29:19 -0500
In-Reply-To: <20070216161045.GA2371@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 16 Feb 2007 19:10:45 +0300
Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> one of the possible fixes for select() after write() after ECONNRESET.
> 
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index b67e0dd..661ca0c 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -365,7 +365,7 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
>  	 * blocking on fresh not-connected or disconnected socket. --ANK
>  	 */
>  	if (sk->sk_shutdown == SHUTDOWN_MASK || sk->sk_state == TCP_CLOSE)
> -		mask |= POLLHUP;
> +		mask |= POLLHUP | POLLERR;
>  	if (sk->sk_shutdown & RCV_SHUTDOWN)
>  		mask |= POLLIN | POLLRDNORM | POLLRDHUP;
>  
> 

No, that would end up setting error bit on normal shutdown. This is incorrect 
behaviour and might even be described in SUSE standard.

There might even be LSB tests on this?

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
