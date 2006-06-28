From: Sam Vilain <sam@vilain.net>
Subject: Re: [patch 2/6] [Network namespace] Network device sharing by view
Date: Wed, 28 Jun 2006 18:31:05 +1200
Message-ID: <44A22229.2090404@vilain.net>
References: <20060609210625.144158000@localhost.localdomain>	<20060626134711.A28729@castle.nmd.msu.ru>	<449FF5A0.2000403@fr.ibm.com> <20060626192751.A989@castle.nmd.msu.ru>	<44A00215.2040608@fr.ibm.com>	<20060627131136.B13959@castle.nmd.msu.ru>	<44A0FBAC.7020107@fr.ibm.com> <44A1006B.3040700@sw.ru>	<20060627160908.GC28984@MAIL.13thfloor.at>	<m1y7vilfyk.fsf@ebiederm.dsl.xmission.com>	<20060627230723.GC2612@MAIL.13thfloor.at> <m1irmlkjni.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Herbert Poetzl <herbert@13thfloor.at>, Kirill Korotaev <dev@sw.ru>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Andrey Savochkin <saw@swsoft.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com,
	Andrew Morton <akpm@osdl.org>, devel@openvz.org,
	viro@ftp.linux.org.uk, Alexey Kuznetsov <alexey@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from watts.utsl.gen.nz ([202.78.240.73]:34991 "EHLO
	watts.utsl.gen.nz") by vger.kernel.org with ESMTP id S932748AbWF1Gag
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 02:30:36 -0400
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m1irmlkjni.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Have a few more network interfaces for a layer 2 solution
> is fundamental.  Believing without proof and after arguments
> to the contrary that you have not contradicted that a layer 2
> solution is inherently slower is non-productive.  Arguing
> that a layer 2 only solution most prove itself on guest to guest
> communication is also non-productive.
>   

Yes, it does break what some people consider to be a sanity condition
when you don't have loopback anymore within a guest. I once experimented
with using 127.* addresses for per-guest loopback devices with vserver
to fix this, but that couldn't work without fixing glibc to not make
assumptions deep in the bowels of the resolver. I logged a fault with
gnu.org and you can guess where it went :-).

I don't think it's just the performance issue, though. Consider also
that if you only have one set of interfaces to manage, the overall
configuration of the network stack is simpler. `ip addr list' on the
host shows all the addresses on the system, you only have one routing
table to manage, one set of iptables, etc.

That being said, perhaps if each guest got its own interface, and from
some suitably privileged context you could see them all, perhaps it
would be nicer and maybe just as fast. Perhaps then *devices* could get
their own routing namespaces, and routing namespaces could get iptables
namespaces, or something like that, to give the most options.

> With a guest with 4 IPs 
> 10.0.0.1 192.168.0.1 172.16.0.1 127.0.0.1
> How do you make INADDR_ANY work with just filtering at bind time?
>   

It used to just bind to the first one. Don't know if it still does.

Sam.
