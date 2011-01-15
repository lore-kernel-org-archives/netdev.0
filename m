From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [PATCH] can: test size of struct sockaddr
Date: Sat, 15 Jan 2011 20:35:27 +0100
Message-ID: <20110115193526.GB463@e-circ.dyndns.org>
References: <20110114172321.GB331@e-circ.dyndns.org>
	<4D31D4A6.4040701@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D31D4A6.4040701-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 15, 2011 at 06:08:54PM +0100, Oliver Hartkopp wrote:
> On 14.01.2011 18:23, Kurt Van Dijck wrote:
> > I think this patch makes the CAN socket code comform to the
> > manpages of sendmsg & recvmsg.
> 
> Hello Kurt,
> 
> if you check similar code sniplets in the kernel you would see, that in
> recvmsg()-cases the given namelen is not used from userspace.
I went into udp code, but my mind got troubled there.
> 
> If msg->msg_name is not NULL the msg_namelen is just set by the kernel. E.g.
> see af_packet.c, af_econet.c, etc.
I should have looked further ...
Given this, I went up to net/socket.c:__sys_recvmsg.
Within kernel space, a struct sockaddr_storage is used in fact ....
This solves indeed the problem I was trying to address.
> 
> So the code in candump.c setting the msg_namelen before recvmsg() is obviously
> obsolete ...
I think no, since after the socket's recvmsg() has been called, 
since move_addr_to_user() will do checks similar as I tried to reimplement.
> 
> Btw. your two patches below for bcm_sendmsg() and raw_sendmesg() look good.
> 
> If you would like to resubmit these two patches, you may add my Acked-by
Thanks, I will do so.

Kurt
