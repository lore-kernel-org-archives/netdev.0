From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: network-namespace and unix-domain-sockets
Date: Fri, 28 Sep 2012 12:29:06 -0700
Message-ID: <87ehlmkku5.fsf@xmission.com>
References: <1348841564.32187.7.camel@pro6455b.example.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: dilip.daya@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:47889 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030292Ab2I1T3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 15:29:14 -0400
In-Reply-To: <1348841564.32187.7.camel@pro6455b.example.com> (Dilip Daya's
	message of "Fri, 28 Sep 2012 10:12:44 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dilip Daya <dilip.daya@hp.com> writes:

> Hi Eric,
>
> => kernel 3.6.0-rc6 + network-namespace + unix-domain-sockets
>
> srv/cli sample programs at:
> <http://tkhanson.net/cgit.cgi/misc.git/plain/unixdomain/Unix_domain_sockets.html>
> Executing UNIX domain sockets between two network-namespaces fails but
> successful if both srv and cli are executed within a network-namespace.
>
> Test results:
>
> (1) Executing both srv and cli within default/host network-namespace:
>
> On host/default netns:
> # ./cli 
> testing...
> ^C
>
> On host/default netns:
> # ./srv 
> read 11 bytes: testing...
>
> EOF
>
>
> (2) Executing srv in default/host netns and cli within netns named
> netns0:
>
> On host/default netns:
> # ip netns
> netns1
> netns0
>
> On host/default netns:
> # ./srv 
>
> Within netns name netns0:
> # ip netns exec netns0 ./cli
> connect error: Connection refused

Yes that is correct behavior.

> => I find difference between __unix_find_socket_byname()  and
>                               *unix_find_socket_byinode()
>
> 	---
> 		if (!net_eq(sock_net(s), net))
> 			continue;
> 	---
>
> => Is there an explanation for why __unix_find_socket_byname() was left
>    netns aware and *unix_find_socket_byinode() is not netns aware ?

The abstract namespace will cause two sockets with the same name
in different network namespaces to conflict.

The network namespace a socket is in is irrelevant for purposes of
conflicts on the filesystem.

There is also a detailed commit message that was written at the time
the per network namespace restrictions were relaxed on
unix_find_socket_byinode if you would like to read it.

> => Please see attached patch. Is this valid? or will it break something?
>    I've tested network namespaces with this patch applied and I did not 
>    find any issues.

Totally invalid.

Eric
