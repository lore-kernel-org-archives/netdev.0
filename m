From: jamal <hadi@cyberus.ca>
Subject: Re: [GENL]: Provide more information to userspace about registered
	genl families
Date: Thu, 31 Aug 2006 17:46:52 -0400
Message-ID: <1157060812.5297.51.camel@jzny2>
References: <20060831212129.GF3470@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:43229 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932374AbWHaVqz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 17:46:55 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GIuNH-0003PB-IR
	for netdev@vger.kernel.org; Thu, 31 Aug 2006 17:46:59 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060831212129.GF3470@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Useful stuff. There are things along these lines that i have been
contemplating myself.

I think it would be valuable to specify a set of flags for filtering
what gets sent to user space instead of unconditionally.

Example, 
filter level 0:
  - what we have before your patch
filter level 1:
  - protocol version
  - header size
  - maximum number of attributes
filter level 2:
  - the rest of the stuff you have
 
What netlink does today to filter at user space is something that can be
avoided with the above (an improvement in my opinion if you have a lot
of genl items in the kernel).

cheers,
jamal

On Thu, 2006-31-08 at 23:21 +0200, Thomas Graf wrote:
> Additionaly exports the following information when providing
> the list of registered generic netlink families:
>   - protocol version
>   - header size
>   - maximum number of attributes
>
>   - list of available operations including
>       - id
>       - flags
>       - avaiability of policy and doit/dumpit function
> 
> libnl HEAD provides a utility to read this new information:
> 
> 	0x0010 nlctrl version 1
> 	    hdrsize 0 maxattr 6
> 	      op GETFAMILY (0x03) [POLICY,DOIT,DUMPIT]
> 	0x0011 NLBL_MGMT version 1
> 	    hdrsize 0 maxattr 0
> 	      op unknown (0x02) [DOIT]
> 	      op unknown (0x03) [DOIT]
> 	      ....
> 


