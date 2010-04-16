From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH net-2.6] packet : remove init_net restriction
Date: Fri, 16 Apr 2010 17:04:28 +0200
Message-ID: <4BC87C7C.4060407@free.fr>
References: <1271322674-21726-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([194.196.100.161]:36526 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756322Ab0DPPEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 11:04:33 -0400
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate1.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o3GF4VMY003166
	for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 15:04:31 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3GF4VmD1528020
	for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 16:04:31 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o3GF4VVI012304
	for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 16:04:31 +0100
In-Reply-To: <1271322674-21726-1-git-send-email-daniel.lezcano@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano wrote:
> The af_packet protocol is used by Perl to do ioctls as reported by
> Stephane Riviere:
>
> "Net::RawIP relies on SIOCGIFADDR et SIOCGIFHWADDR to get the IP and MAC
> addresses of the network interface."
>
> But in a new network namespace these ioctl fail because it is disabled for
> a namespace different from the init_net_ns.
>
> These two lines should not be there as af_inet and af_packet are
> namespace aware since a long time now. I suppose we forget to remove these
> lines because we sent the af_packet first, before af_inet was supported.
>
> Signed-off-by: Daniel Lezcano <daniel.lezcano@free.fr>
> Reported-by: Stephane Riviere <stephane.riviere@regis-dgac.net>
> ---
>  net/packet/af_packet.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index cc90363..243946d 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -2169,8 +2169,6 @@ static int packet_ioctl(struct socket *sock, unsigned int cmd,
>  	case SIOCGIFDSTADDR:
>  	case SIOCSIFDSTADDR:
>  	case SIOCSIFFLAGS:
> -		if (!net_eq(sock_net(sk), &init_net))
> -			return -ENOIOCTLCMD;
>  		return inet_dgram_ops.ioctl(sock, cmd, arg);
>  #endif
>  
>   
Shall I send it against net-next-2.6 ?

Thanks
  -- Daniel
