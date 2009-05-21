From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Thu, 21 May 2009 11:47:39 -0300
Message-ID: <20090521144739.GF5956@ghostprotocols.net>
References: <20090520230652.GB5956@ghostprotocols.net> <200905211016.17328.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>,
	linux-security-module@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36634 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751138AbZEUOrn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 10:47:43 -0400
Content-Disposition: inline
In-Reply-To: <200905211016.17328.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, May 21, 2009 at 10:16:17AM -0400, Paul Moore escreveu:
> On Wednesday 20 May 2009 07:06:52 pm Arnaldo Carvalho de Melo wrote:
> > Meaning receive multiple messages, reducing the number of syscalls and
> > net stack entry/exit operations.
> 
> NOTE: adding the LSM list to the CC line

thanks!
 
> If this approach is accepted I wonder if it would also make sense to move the 
> security_socket_recvmsg() hook out of __sock_recvmsg and into the callers.  I 
> personally can't see a reason why we would need to call into the LSM for each 
> message in the case of the new recvmmsg() syscall.  The downside is that there 
> is now some code duplication (although we are only talking duplicating ~three 
> lines of code) but the upside is that we wont end up calling into the LSM for 
> each of the messages when recvmmsg() is called which seems to fit well with 
> the performance oriented nature of the new syscall.

Agreed that we must do this earlier to avoind vlen calls to
security_socket_recvmsg, but there are many callers of sock_recvmsg...

Also shouldn't recvmmsg have a different LSM hook? It doesn't look right
at first sight to reuse security_socket_recvmsg, as we now are passing
many msghdrs and sockaddrs, etc.

If security_socket_recvmsg receives the msg and inspects it, I think
fully inspecting the mmsg and vlen can be something LSM policies can be
interested in inspecting too, no?

- Arnaldo
