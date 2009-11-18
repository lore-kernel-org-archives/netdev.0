From: Jeff Haran <jharan@Brocade.COM>
Subject: RE: NETLINK sockets dont honor SO_RCVLOWAT?
Date: Wed, 18 Nov 2009 10:41:06 -0800
Message-ID: <D67825C5985D0647BE40A5F5B0B70D1106E9C568FE@HQ-EXCH-7.corp.brocade.com>
References: <D67825C5985D0647BE40A5F5B0B70D1106E9C56894@HQ-EXCH-7.corp.brocade.com>
	<20091117.231706.125598146.davem@davemloft.net>
	<D67825C5985D0647BE40A5F5B0B70D1106E9C568F1@HQ-EXCH-7.corp.brocade.com>
 <20091118.102434.160976750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.82]:14049 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752736AbZKRSlB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 13:41:01 -0500
In-Reply-To: <20091118.102434.160976750.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Wednesday, November 18, 2009 10:25 AM
> To: Jeff Haran
> Cc: netdev@vger.kernel.org
> Subject: Re: NETLINK sockets dont honor SO_RCVLOWAT?
> 
> From: Jeff Haran <jharan@Brocade.COM>
> Date: Wed, 18 Nov 2009 10:22:54 -0800
> 
> > So is this a bug or a feature?
> 
> It definitely seems intentional.
> 
> > When I call setsockopt() to set this option on a NETLINK socket,
> > setsockopt() appears to return 0 to indicate success. If it's not
> > going to be supported, shouldn't setsockopt() return -1 with
> > ENOPROTOOPT in errno in this case?
> 
> There are a lot of socket option values that can be set but which
> are not used by the protocol in question.

All that means is that there are a lot of bugs.

> 
> I don't think any changes need to be made.

>From the setsockopt man page:

SETSOCKOPT(P)                                                   SETSOCKOPT(P)

NAME
       setsockopt - set the socket options

SYNOPSIS
       #include <sys/socket.h>

       int setsockopt(int socket, int level, int option_name,
              const void *option_value, socklen_t option_len);
...

ERRORS
       The setsockopt() function shall fail if:
...

       ENOPROTOOPT

              The option is not supported by the protocol.


The operative term is "shall". The RFCs define "shall" to be required behavior. I realize the RFCs do not dictate how Linux works, but even the common English language usage of the word "shall" conveys this meaning.

Thanks,

Jeff Haran
Brocade Communications
