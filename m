From: abdallah.chatila@ericsson.com (Abdallah Chatila)
Subject: Re: Network namespaces a path to mergable code.
Date: Wed, 28 Jun 2006 01:59:18 -0400
Message-ID: <20060628055918.GA5614@dolphin.dyn.rnet.lmc.ericsson.se>
References: <20060626134945.A28942@castle.nmd.msu.ru> <m14py6ldlj.fsf@ebiederm.dsl.xmission.com> <20060627215859.A20679@castle.nmd.msu.ru> <44A1AF37.3070100@vilain.net> <m1ac7xkifn.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sam Vilain <sam@vilain.net>, Andrey Savochkin <saw@swsoft.com>,
	dlezcano@fr.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, serue@us.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com, Andrew Morton <akpm@osdl.org>, dev@sw.ru,
	herbert@13thfloor.at, devel@openvz.org, viro@ftp.linux.org.uk,
	Alexey Kuznetsov <alexey@sw.ru>,
	Mark Huang <mlhuang@CS.Princeton.EDU>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:64397 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1161139AbWF1F6L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 01:58:11 -0400
To: "Eric W. Biederman" <ebiederm@xmission.com>
Content-Disposition: inline
In-Reply-To: <m1ac7xkifn.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 27, 2006 at 10:33:48PM -0600, Eric W. Biederman wrote:
> 
> Something to examine here is that if both network devices and sockets
> are tagged does that still allow implicit network namespace passing.

I think avoiding implicit network namespace passing expresses more
power/flexibility plus it would make things clearer to what
container/namespace a given network resource belongs too.

>From our experience with an implementation of network containers [Virtual
Routing for ipv4/ipv6, with a complete isolation between containers where ip
addresses can overlap...], there is some problem domain in which you cannot
afford to duplicate a process/daemon in each container [a big process for
instance, scalability w.r.t. number of containers etc]

By having a proper namespace tag per socket, this can be solved by allowing
a process running in the host context to create sockets in that namespace
than moving them to the target guest namespaces [via a special setsockopt
for instance or unix domain socket as you said].


Regards

> 
> Eric
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
