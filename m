From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: recvmmsg() timeout behavior strangeness
Date: Thu, 10 Jan 2013 09:24:47 -0600
Message-ID: <50EEDD3F.9080203@genband.com>
References: <CAHO5Pa2goUtiBU8ye2beTBExL4it2-aDCPBhDOGyO3NX_PV_pQ@mail.gmail.com>	 <50EDF01E.10709@genband.com> <1357812249.2760.6.camel@menhir>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Kerrisk <mtk.manpages@gmail.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Andrew Grover <andy.grover@gmail.com>,
	Elie De Brauwer <eliedebrauwer@gmail.com>,
	linux-man@vger.kernel.org,
	=?ISO-8859-1?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: Steven Whitehouse <steve@chygwyn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og108.obsmtp.com ([64.18.2.169]:50767 "EHLO
	exprod7og108.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753487Ab3AJP1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 10:27:06 -0500
In-Reply-To: <1357812249.2760.6.camel@menhir>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2013 04:04 AM, Steven Whitehouse wrote:

> Which timeout are we talking about? I've been copied into the thread
> without seeing the start of it.

The discussion is about the timeout parameter for the recvmmsg() call. 
Currently in the recvmmsg() code it only checks the timeout after 
__sys_recvmsg() returns, so if __sys_recvmsg() blocks forever we could 
end up essentially ignoring the timeout.

> If this is the rcvtimeo then afaik this is supposed to be the max time
> that the call waits for data, but is overridden by MSG_DONTWAIT, for
> example, on a per call basis. I'd assume that recvmmsg should work
> exactly like recvmsg in this case unless there is a good reason for it
> to differ,

recvmsg() doesn't have a timeout parameter, so it uses SO_RCVTIMEO.

recvmmsg() has an explicit timeout parameter but it doesn't look like it 
works properly and the documentation doesn't mention how it is supposed 
to interact with SO_RCVTIMEO.

Chris
