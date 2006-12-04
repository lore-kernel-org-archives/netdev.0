From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: Network virtualization/isolation
Date: Mon, 04 Dec 2006 11:18:09 +0100
Message-ID: <4573F5E1.8040606@fr.ibm.com>
References: <453F8800.9070603@fr.ibm.com>	<45408397.8070404@fr.ibm.com>	<20061026085659.33b4c6dd@freekitty>	<200610271134.56830.dim@openvz.org>	<4541CCF4.4050306@fr.ibm.com>	<1162391707.5251.78.camel@jzny2>	<4559DE01.5090109@fr.ibm.com>	<m1y7pzoptr.fsf@ebiederm.dsl.xmission.com>	<456C447E.5090703@fr.ibm.com>	<m1r6vnikeq.fsf@ebiederm.dsl.xmission.com>	<456C9B8C.1010701@fr.ibm.com> <m14psji6lw.fsf@ebiederm.dsl.xmission.com>	<456DEBAC.4060106@hp.com>  <456E055F.8020100@fr.ibm.com> <1165148762.3517.58.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: devel@openvz.org, "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org, Dmitry Mishin <dim@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:50293 "EHLO
	mtagate1.uk.ibm.com") by vger.kernel.org with ESMTP id S935588AbWLDKS1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 05:18:27 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kB4AIMSN095414
	for <netdev@vger.kernel.org>; Mon, 4 Dec 2006 10:18:25 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB4AIMW22416678
	for <netdev@vger.kernel.org>; Mon, 4 Dec 2006 10:18:22 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB4AILvu007051
	for <netdev@vger.kernel.org>; Mon, 4 Dec 2006 10:18:22 GMT
To: hadi@cyberus.ca
In-Reply-To: <1165148762.3517.58.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jamal,

thanks for taking the time read the document.

The objective of the document was not to convince one approach is better 
than other. I wanted to show the pros and the cons of each approach and 
to point that the 2 approaches are complementary.

Currently, there are some resources moved to a namespace relative 
access, the IPC and the utsname and this is into the 2.6.19 kernel.
The work on the pid namespace is still in progress.

The idea is to use a "clone" approach relying on the "unshare_ns" 
syscall. The syscall is called with a set of flags for pids, ipcs, 
utsname, network ... You can then "unshare" only the network and have an 
application into its own network environment.

For a l3 approach, like a l2, you can run an apache server into a 
unshared network environment. Better, you can run several apaches server 
into several network namespaces without modifying the server's network 
configuration.

Some of us, consider l2 as perfectly adapted for some kind of containers 
  like system containers and some kind of application containers running 
big servers, but find the l2 too much (seems to be a hammer to crush a 
beetle) for simple network requirements like for network migration, 
jails or containers which does not take care of such virtualization. For 
example, you want to create thousands of containers for a cluster of HPC 
jobs and just to have migration for these jobs. Does it make sense to 
have l2 approach ?

Dmitry Mishin and I, we thought about a l2/l3 solution and we thing we 
found a solution to have the 2 at runtime. Roughly, it is a l3 based on 
bind filtering and socket isolation, very similar to what vserver 
provides. I did a prototype, and it works well for IPV4/unicast.

So, considering, we have a l2 isolation/virtualization, and having a l3 
relying on the l2 network isolation resources subset. Is it an 
acceptable solution ?

   -- Daniel


