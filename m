From: Nagendra Tomar <tomer_iisc@yahoo.com>
Subject: Re: [PATCH] net: Fix __inet_inherit_port() to correctly increment bsockets and num_owners
Date: Fri, 26 Nov 2010 01:40:12 -0800 (PST)
Message-ID: <751926.73238.qm@web53707.mail.re2.yahoo.com>
References: <1290759801.2855.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web53707.mail.re2.yahoo.com ([206.190.37.28]:42434 "HELO
	web53707.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754061Ab0KZJkN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Nov 2010 04:40:13 -0500
In-Reply-To: <1290759801.2855.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--- On Fri, 26/11/10, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> 
> OK so you'll have to make a proof, because current code
> seems to work ;)
> 
> 

ok, so I printed hashinfo->bsockets and tb->num_owners inside __inet_put_port() and I could see both of them to be -ve. All we need to do is establish and terminate a connection. I used netcat for that.

The only place 'bsockets' and 'num_owners' are used is inet_csk_get_port() and the only effect that they might have is on the choice of the port to be used for binding. 
'bsockets' is used as a hint to stop searching for a free port (and instead share an already used port) when we know that all the ports could be used up.
'num_owners' is used to find the port which is least shared (to balance the 'owners' list) in case we need to share a port.

Since both of these are used as optimizations (in the bind path), they do not affect correctness and hence the code works even with these values not being updated correctly.

Thanks,
Tomar


      
