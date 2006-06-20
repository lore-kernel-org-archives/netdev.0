From: jamal <hadi@cyberus.ca>
Subject: Re: [DOC]: generic netlink
Date: Tue, 20 Jun 2006 09:19:12 -0400
Message-ID: <1150809552.5270.5.camel@jzny2>
References: <1150724482.5815.48.camel@jzny2>
	 <Pine.LNX.4.64.0606191057420.21114@d.namei>
	 <1150730884.5384.10.camel@jzny2>  <4496C98E.8030407@watson.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@namei.org>,
	Per Liden <per.liden@ericsson.com>,
	Jay Lan <jlan@engr.sgi.com>, Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:28063 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1750768AbWFTNTQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 09:19:16 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1Fsg8U-0004cJ-69
	for netdev@vger.kernel.org; Tue, 20 Jun 2006 09:19:18 -0400
To: Shailabh Nagar <nagar@watson.ibm.com>
In-Reply-To: <4496C98E.8030407@watson.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-19-06 at 11:58 -0400, Shailabh Nagar wrote: 
> jamal wrote:
[..]

> But I'm not too clear about what are the advantages of trying to limit the
> number of commands registered by a given exploiter of genetlink (say TIPC or taskstats),
> other than the conventional usage of netlink.
> 
> e.g in the taskstats code, userspace needs to GET data on a per-pid and per-tgid basis
> from the kernel and supplies the specific pid or tgid. We could either have registered
> two commands (say GET_PID and GET_TGID) and then the parsing of the supplied uint32 would
> be implicit in the command. But we went with the model where we have only one GET command
> and the type of the parameter is specified via netlink attributes.

The idea is for fine grain access control(ACL) of what user process can
do (as managed by SELinux not genetlink). As an example even in your
case, you may wanna allow user program "shailab1" to be able to get
information on a groupid but not pid. We should be able to add that
level of granularity easily since we have flags per command.

> In our case, it didn't matter and since the type of data returned is very similar and so is
> the parameter supplied (pid/tgid), one GET suffices. But I'm wondering if userspace should
> consciously try and limit the commands or would it be better from a performance standpoint,
> to permit a reasonably larger "fan-out" to happen at the genetlink command level (for each exploiter).
> I guess this introduces more overhead for in-kernel structures (the linked list of command structures
> that needs to be kept around) while saving time on doing a second level of parsing within the
> exploiter-defined function that services the GET command.
> 
> The "small" set model looks like a good compromise. Reducing number of commands to one is not a good
> idea IMHO....for reasons similar to why ioctl type syscalls aren't encouraged...since the genetlink
> layer anyway has code for demultiplexing, might as well use it and avoid an extra level of indirection.
> 

indeed.

cheers,
jamal

