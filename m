From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Inconsistency in number of Unix sockets
Date: Tue, 30 Jun 2009 13:29:03 +0200
Message-ID: <4A49F6FF.60608@cosmosbay.com>
References: <31436f4a0906290737w7eba05a7r5e2ab96b4b2838a2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Shwatrz <dshwatrz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60425 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869AbZF3L3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 07:29:16 -0400
In-Reply-To: <31436f4a0906290737w7eba05a7r5e2ab96b4b2838a2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Shwatrz a écrit :
> Hello,
> 
> On kernel 2.6.29.4-167: (Fedora 11):
> 
> Why is this inconsistency in number of Unix sockets, when running the following:
> 
>  cat /proc/net/protocols | grep UNIX
> UNIX       432    986      -1   ....
> 
> lsof -U | wc -l
> 989
> 
> netstat --unix | wc -l
> 906
> 
> cat /proc/net/unix | wc -l
> 986
> 
> On which of this statistics should we rely when we want to know how
> many Unix Domain sockets do we have ? There is a variable named unix_nr_socks,
> but AFAIK, the patch which used it (for /proc/net/protocols ) was
> reverted lately.

Pick your own definition of what is "the number of unix sockets".

"lsof -U | wc -l " cannot be right because of shared file descriptors
(one socket shared by several processes)

"netstat --unix" seems to not display some sockets (which names dont
start by / or @ , like in "private/smtp")

If you use "netstat --unix --all", then all sockets are displayed.

> 
> commit 1748376b6626acf59c24e9592ac67b3fe2a0e026
> by Eric Dumazet <dada1@cosmosbay.com>

You didnt understand this patch.

Information is still available in /proc/net/protocols

$ grep UNIX /proc/net/protocols
UNIX       432     98      -1   NI       0   yes  kernel      n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n  n
$ wc -l /proc/net/unix
99 /proc/net/unix
