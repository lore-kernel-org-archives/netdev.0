From: Andi Kleen <ak@suse.de>
Subject: Re: Ambiguities in TCP/IP - firewall bypassing (fwd)
Date: Sun, 20 Oct 2002 06:35:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021020063535.A6016@wotan.suse.de>
References: <Pine.LNX.4.44.0210191437230.12141-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0210191437230.12141-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Oct 19, 2002 at 02:38:56PM +0300, Pekka Savola wrote:
> See the thread on bugtraq.
> 
> Linux 2.4.19 initiates TCP handshake with SYN and RST bits set.  SYN with 
> _RST_ seems like a total nonsense (SYN with FIN might even be useful for 
> stuff like T/TCP) but I guess the spec didn't take any stance on that..

Here is a patch to fix it for 2.4.19.


--- linux/net/ipv4/tcp_input.c-o	2002-10-15 17:24:53.000000000 +0200
+++ linux/net/ipv4/tcp_input.c	2002-10-20 06:34:05.000000000 +0200
@@ -3664,6 +3664,9 @@
 		goto discard;
 
 	case TCP_LISTEN:
+		if(th->rst) 
+			goto discard;
+
 		if(th->ack)
 			return 1;
 


-Andi
