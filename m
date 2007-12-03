From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.25] Add packet filtering based on process's security
 context.
Date: Mon, 03 Dec 2007 08:58:59 +0100
Message-ID: <4753B743.2090501@trash.net>
References: <200711212130.EJJ43745.LFOFHOSMJOtFVQ@I-love.SAKURA.ne.jp> <200711222235.GCA05378.HtMOJQVFSFOLFO@I-love.SAKURA.ne.jp> <Xine.LNX.4.64.0711231005270.4252@us.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-security-module@vger.kernel.org,
	netfilter-devel@lists.netfilter.org,
	Stephen Smalley <sds@tycho.nsa.gov>
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57561 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbXLCH7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 02:59:12 -0500
In-Reply-To: <Xine.LNX.4.64.0711231005270.4252@us.intercode.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Morris wrote:
> On Thu, 22 Nov 2007, Tetsuo Handa wrote:
> 
>> This patch allows LSM modules filter incoming connections/datagrams
>> based on the process's security context who is attempting to pick up.
>>
>> There are already hooks to filter incoming connections/datagrams
>> based on the socket's security context, but these hooks are not
>> applicable when one wants to do TCP Wrapper-like filtering
>> (e.g. App1 is permitted to accept TCP connections from 192.168.0.0/16).
> 
> This functionality looks like it could be useful in that we currently have 
> no direct security mapping from incoming packet to user process, but only 
> to the receiving socket, as you mention.  For SELinux, it may help us 
> simplify/clarify policy.
> 
> It's also been long-desired for netfilter/iptables, to allow ipt_owner to 
> work cleanly for incoming packets.
> 
> So, this probably needs to be implemented in a way which works for both LSM 
> and netfilter.  There have been several discussions on the issue from the 
> netfilter side, although I don't know what the latest status of that is 
> (I've expanded the cc list to hopefully get some more feedback).

No news on that. I'm also a bit sceptical if adding all this complexity
and overhead would really be worth it (considering only netfilter) just
to use the owner match and UID/GID matching. It wouldn't even be
accurate because there is not 1:1 mapping of sockets and processes.

I actually like Samir Bellabes' approach, which doesn't suffer from
these problems IIRC.

>>From memory, one approach under discussion was to add netfilter hooks to 
> the transport layer, which could be invoked correctly by each type of 
> protocol when the target process is selected.

We can only invoke the hooks after the socket lookup, but we don't
know which process is going to call recvmsg() for that socket.
