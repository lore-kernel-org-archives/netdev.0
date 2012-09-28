From: Dilip Daya <dilip.daya@hp.com>
Subject: Re: network-namespace and unix-domain-sockets
Date: Fri, 28 Sep 2012 15:51:42 -0400
Message-ID: <1348861902.32187.18.camel@pro6455b.example.com>
References: <1348841564.32187.7.camel@pro6455b.example.com>
	 <87ehlmkku5.fsf@xmission.com>
Reply-To: dilip.daya@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:48402 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030235Ab2I1Tvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 15:51:45 -0400
In-Reply-To: <87ehlmkku5.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

I very much appreciate your quick response!.  I found it:
<http://lists.linux-foundation.org/pipermail/containers/2010-June/024725.html>

Thanking you for your time and effort.
-DilipD.

On Fri, 2012-09-28 at 12:29 -0700, Eric W. Biederman wrote:
> Dilip Daya <dilip.daya@hp.com> writes:
> 
> > Hi Eric,
> >
> > => kernel 3.6.0-rc6 + network-namespace + unix-domain-sockets
> >
> > srv/cli sample programs at:
> > <http://tkhanson.net/cgit.cgi/misc.git/plain/unixdomain/Unix_domain_sockets.html>
> > Executing UNIX domain sockets between two network-namespaces fails but
> > successful if both srv and cli are executed within a network-namespace.
> >
> > Test results:
> >
> > (1) Executing both srv and cli within default/host network-namespace:
> >
> > On host/default netns:
> > # ./cli 
> > testing...
> > ^C
> >
> > On host/default netns:
> > # ./srv 
> > read 11 bytes: testing...
> >
> > EOF
> >
> >
> > (2) Executing srv in default/host netns and cli within netns named
> > netns0:
> >
> > On host/default netns:
> > # ip netns
> > netns1
> > netns0
> >
> > On host/default netns:
> > # ./srv 
> >
> > Within netns name netns0:
> > # ip netns exec netns0 ./cli
> > connect error: Connection refused
> 
> Yes that is correct behavior.
> 
> > => I find difference between __unix_find_socket_byname()  and
> >                               *unix_find_socket_byinode()
> >
> > 	---
> > 		if (!net_eq(sock_net(s), net))
> > 			continue;
> > 	---
> >
> > => Is there an explanation for why __unix_find_socket_byname() was left
> >    netns aware and *unix_find_socket_byinode() is not netns aware ?
> 
> The abstract namespace will cause two sockets with the same name
> in different network namespaces to conflict.
> 
> The network namespace a socket is in is irrelevant for purposes of
> conflicts on the filesystem.
> 
> There is also a detailed commit message that was written at the time
> the per network namespace restrictions were relaxed on
> unix_find_socket_byinode if you would like to read it.
> 
> > => Please see attached patch. Is this valid? or will it break something?
> >    I've tested network namespaces with this patch applied and I did not 
> >    find any issues.
> 
> Totally invalid.
> 
> Eric
