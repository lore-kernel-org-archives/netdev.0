From: Samir Bellabes <sam@synack.fr>
Subject: Re: [PATCH 2/2] Create a new connector proc_event for successful calls to accept.
Date: Wed, 03 Aug 2011 17:02:55 +0200
Message-ID: <87r55235cw.fsf@synack.fr>
References: <1312221865-3012-1-git-send-email-joe@boundary.com>
	<1312221865-3012-3-git-send-email-joe@boundary.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zbr@ioremap.net, netdev@vger.kernel.org
To: Joe Damato <joe@boundary.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp22.services.sfr.fr ([93.17.128.12]:40638 "EHLO
	smtp22.services.sfr.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754579Ab1HCPDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 11:03:01 -0400
Received: from smtp22.services.sfr.fr (msfrf2201 [10.18.26.15])
	by msfrf2210.sfr.fr (SMTP Server) with ESMTP id 54F9A70003D3
	for <netdev@vger.kernel.org>; Wed,  3 Aug 2011 17:03:00 +0200 (CEST)
In-Reply-To: <1312221865-3012-3-git-send-email-joe@boundary.com> (Joe Damato's
	message of "Mon, 1 Aug 2011 11:04:25 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Damato <joe@boundary.com> writes:

> diff --git a/net/socket.c b/net/socket.c
> index b4f9a6c..d21a266 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1544,6 +1544,9 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
>  			goto out_fd;
>  	}
>  
> +	proc_accept_connector(current, newsock,
> +			      (struct sockaddr *)&address, len);
> +
>  	/* File flags are not inherited via accept() unlike another OSes. */
>  
>  	fd_install(newfd, newfile);

Hi Joe,
adding a specific function here is not very suitable.
I have already proposed such a patch by adding my own hooks, then I
moved to the LSM hooks
http://www.mail-archive.com/netdev@vger.kernel.org/msg33814.html

I have rewrite the projet to directly use netlink socket (in fact
generic netlink socket) and move to a new protocol between userspace and
kernel
you can find patch here :
http://www.synack.fr/project/snet/snet.html

sam

