From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 0/1] RFC: poll/select performance on datagram sockets
Date: Fri, 29 Oct 2010 14:57:28 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1010291451330.8517@davide-lnx1>
References: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>  <1288380431.2680.3.camel@edumazet-laptop>  <alpine.DEB.2.00.1010291306390.8517@davide-lnx1>  <alpine.DEB.2.00.1010291339180.8517@davide-lnx1> <1288386348.2680.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alban Crequy <alban.crequy@collabora.co.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Pauli Nieminen <pauli.nieminen@collabora.co.uk>,
	Rainer Weikusat <rweikusat@mssgmbh.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:55396 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755739Ab0J2V66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 17:58:58 -0400
Received: from l-sjc-pzhang.corp.ebay.com
	by x35.xmailserver.org with [XMail 1.27 ESMTP Server]
	id <S36099B> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Fri, 29 Oct 2010 17:57:55 -0400
In-Reply-To: <1288386348.2680.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Oct 2010, Eric Dumazet wrote:

> Following patch solves the problem for me, and its only a start, I am
> pretty sure we can optimize more than that.
> 
> What I did is to move "struct poll_wqueues table;" out of do_select()
> in its caller. This structure is highly modified by an other cpu in
> Alban workload, and this slow down do_select() because many accesses to
> some of its local variables (normally, private ones !) hit a false
> sharing.
> 
> Before :
> 
> # time /root/uclient connected
> The performance problem will be triggered
> select: begin
> select: end: 3 seconds
> 
> real	0m3.101s
> user	0m0.000s
> sys	0m6.104s
> 
> After :
> 
> # time /root/uclient connected
> The performance problem will be triggered
> select: begin
> select: end: 1 seconds
> 
> real	0m1.041s
> user	0m0.004s
> sys	0m2.040s
> 
> 
> Impressive no ?

It is, though I am not sure that shuffling code around to chase false 
sharing on very specific cases, is an approach worth following.
The new position of the table on the stack might share with another hot 
line, under a different load.


- Davide


