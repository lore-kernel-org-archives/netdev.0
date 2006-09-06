From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [RFC] network namespaces
Date: Wed, 06 Sep 2006 22:25:10 +0200
Message-ID: <44FF2EA6.2030303@fr.ibm.com>
References: <20060815182029.A1685@castle.nmd.msu.ru>	<20060816115313.GC31810@sergelap.austin.ibm.com>	<44FD7CF0.4030009@fr.ibm.com> <m1k64i1br2.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, netdev@vger.kernel.org,
	"Serge E. Hallyn" <serue@us.ibm.com>, Andrey Savochkin <saw@sw.ru>,
	haveblue@us.ibm.com, herbert@13thfloor.at, sam@vilain.net,
	Andrew Morton <akpm@osdl.org>, dev@sw.ru, devel@openvz.org,
	alexey@sw.ru, Linux Containers <containers@lists.osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:35801 "EHLO e6.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751575AbWIFUZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 16:25:23 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k86KPOXC024782
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 16:25:24 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k86KPNXC239644
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 16:25:23 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k86KPLuk022489
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 16:25:22 -0400
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m1k64i1br2.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
>> This family of containers are used too for HPC (high performance computing) and
>> for distributed checkpoint/restart. The cluster runs hundred of jobs, spawning
>> them on different hosts inside an application container. Usually the jobs
>> communicates with broadcast and multicast.
>> Application containers does not care of having different MAC address and rely on
>> a layer 3 approach.
> 
> Ok I think to understand this we need some precise definitions.
> In the normal case it is an error for a job to communication with a different
> job.  

hmm ? What about an MPI application ?

I would expect each MPI task to be run in its container on different nodes
or on the same node. These individual tasks _communicate_ between each
other through the MPI layer (not only TCP btw) to complete a large calculation.

> The basic advantage with a different MAC is that you can found out who the
> intended recipient is sooner in the networking stack and you have truly
> separate network devices.  Allowing for a cleaner implementation.
> 
> Changing the MAC after migration is likely to be fine.

indeed.

C.

