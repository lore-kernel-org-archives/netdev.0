From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bugfix for iproute2
Date: Tue, 10 Nov 2009 09:12:16 -0800
Message-ID: <20091110091216.43c6eeb0@nehalam>
References: <4AEF6F14.7080802@anduras.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Sven Anders <anders@anduras.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49059 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755153AbZKJRMg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 12:12:36 -0500
In-Reply-To: <4AEF6F14.7080802@anduras.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 03 Nov 2009 00:45:24 +0100
Sven Anders <anders@anduras.de> wrote:

> Hello!
> 
> I already send this mail to Stephen Hemminger, but I'm not sure if it reached him.
> Moreover I tried to join the LARTC mailing list (http://mailman.ds9a.nl/mailman/listinfo/lartc)
> but it did not work. Is this mailing list dead?
> Therefore I sent this mail again over this mailing list...
> 
> 
> I experienced an error, if I try to perform a
> 
>   ip route flush proto 4
> 
> with many routes in a complex environment, it
> gave me the following error:
> 
>   Failed to send flush request: Success
>   Flush terminated
> 
> I'm using version 2.6.29.
> I check GIT, but there was only the "MSG_PEEK" fix.
> 
> I tracked it down to the rtnl_send_check() function
> in lib/libnetlink.c.
> 
> In this function there is the following for loop:
> 
>         for (h = (struct nlmsghdr *)resp; NLMSG_OK(h, status);
>              h = NLMSG_NEXT(h, status)) {
>                 if (h->nlmsg_type == NLMSG_ERROR) {
>                         struct nlmsgerr *err = (struct nlmsgerr*)NLMSG_DATA(h);
>                         if (h->nlmsg_len < NLMSG_LENGTH(sizeof(struct nlmsgerr)))
>                                 fprintf(stderr, "ERROR truncated\n");
>                         else
>                                 errno = -err->error;
> 		}
>                 return -1;
>         }
> 
> I think the "return -1;" should be inside the if statement.
> 
> I attached a patch for this. The first part of the patch is taken from
> one of the late git commits.
> 
> Please note me, if the fix is wrong...
> 
> Regards
>  Sven Anders
> 

Applied thanks.

-- 
