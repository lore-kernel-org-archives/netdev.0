From: jamal <hadi@cyberus.ca>
Subject: Re: Network virtualization/isolation
Date: Mon, 04 Dec 2006 08:22:37 -0500
Message-ID: <1165238557.3664.35.camel@localhost>
References: <453F8800.9070603@fr.ibm.com>	<45408397.8070404@fr.ibm.com>
	 <20061026085659.33b4c6dd@freekitty>	<200610271134.56830.dim@openvz.org>
	 <4541CCF4.4050306@fr.ibm.com>	<1162391707.5251.78.camel@jzny2>
	 <4559DE01.5090109@fr.ibm.com>	<m1y7pzoptr.fsf@ebiederm.dsl.xmission.com>
	 <456C447E.5090703@fr.ibm.com>	<m1r6vnikeq.fsf@ebiederm.dsl.xmission.com>
	 <456C9B8C.1010701@fr.ibm.com> <m14psji6lw.fsf@ebiederm.dsl.xmission.com>
	 <456DEBAC.4060106@hp.com>  <456E055F.8020100@fr.ibm.com>
	 <1165148762.3517.58.camel@localhost>  <4573F5E1.8040606@fr.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: devel@openvz.org, "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org, Dmitry Mishin <dim@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.235]:5895 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S936815AbWLDNWo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 08:22:44 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1855125nze
        for <netdev@vger.kernel.org>; Mon, 04 Dec 2006 05:22:41 -0800 (PST)
To: Daniel Lezcano <dlezcano@fr.ibm.com>
In-Reply-To: <4573F5E1.8040606@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel,

On Mon, 2006-04-12 at 11:18 +0100, Daniel Lezcano wrote:
> Hi Jamal,


> Currently, there are some resources moved to a namespace relative 
> access, the IPC and the utsname and this is into the 2.6.19 kernel.
> The work on the pid namespace is still in progress.
> 
> The idea is to use a "clone" approach relying on the "unshare_ns" 
> syscall. The syscall is called with a set of flags for pids, ipcs, 
> utsname, network ... You can then "unshare" only the network and have an 
> application into its own network environment.
> 

Ok, so i take it this call is used by the setup manager on the host
side?

> For a l3 approach, like a l2, you can run an apache server into a 
> unshared network environment. Better, you can run several apaches server 
> into several network namespaces without modifying the server's network 
> configuration.
> 

ok - as i understand it now, this will be the case for all the
approaches taken?

> Some of us, consider l2 as perfectly adapted for some kind of containers 
>   like system containers and some kind of application containers running 
> big servers, but find the l2 too much (seems to be a hammer to crush a 
> beetle) for simple network requirements like for network migration, 
> jails or containers which does not take care of such virtualization. For 
> example, you want to create thousands of containers for a cluster of HPC 
> jobs and just to have migration for these jobs. Does it make sense to 
> have l2 approach ?
> 

Perhaps not for the specific app you mentioned above.
But it makes sense for what i described as virtual routers/bridges.
I would say that the solution has to cater for a variety of
applications, no?

> Dmitry Mishin and I, we thought about a l2/l3 solution and we thing we 
> found a solution to have the 2 at runtime. Roughly, it is a l3 based on 
> bind filtering and socket isolation, very similar to what vserver 
> provides. I did a prototype, and it works well for IPV4/unicast.
> 

ok - so you guys seem to be reaching at least some consensus then.

> So, considering, we have a l2 isolation/virtualization, and having a l3 
> relying on the l2 network isolation resources subset. Is it an 
> acceptable solution ?

As long as you can be generic enough so that a wide array of apps can be
met, it should be fine. For a test app, consider the virtual
bridges/routers i mentioned. 
The other requirement i would see is that apps that would run on a host
would run unchanged. The migration of containers you folks seem to be
having under control - my only input into that thought since it is early
enough, you may want to build your structuring in such a way that this
is easy to do.

cheers,
jamal


