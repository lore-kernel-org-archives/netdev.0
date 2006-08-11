From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [IPROUTE]: Fix struct alignment with cris architecture
Date: Fri, 11 Aug 2006 09:45:04 -0700
Message-ID: <20060811094504.45c9ab31@localhost.localdomain>
References: <1155255940.7302.18.camel@tahini.andynet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:43411 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750758AbWHKQpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 12:45:15 -0400
To: Andy Gay <andy@andynet.net>
In-Reply-To: <1155255940.7302.18.camel@tahini.andynet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 Aug 2006 20:25:40 -0400
Andy Gay <andy@andynet.net> wrote:

> [IPROUTE]: Fix struct alignment with cris architecture
> 
> gcc for the cris arch does not pad structures to the next multiple of 4
> bytes, as the i386 gcc does.
> 
> This causes errors like this when displaying xfrm policies:
> 
> # ip x p
> !!!Deficit 3, rta_len=300
> src 192.168.251.32/29 dst 192.168.251.32/29 
>         dir in priority 0 
> !!!Deficit 3, rta_len=180
> src 0.0.0.0/0 dst 192.168.251.32/29 
>         dir in priority 2208 
> ....
> 
> Similar errors are seen from ip x s.
> 
> This patch fixes the errors when printing. I'm not sure whether we
> should worry about other uses of the affected structs, I've not seen any
> other bad effects from this though, so hopefully this is enough.
> 
> (Thanks to Herbert Xu for pointing out that NLMSG_SPACE is the correct
> macro to use here.)
> 
> Tested against 2.6.17.6 kernel on i386, and 2.6.16.1 kernel on cris.
> 
> Signed-off-by: Andy Gay <andy@andynet.net>

Applied
