From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: Checkpoint and Restart of INET routing information
Date: Wed, 28 Apr 2010 16:24:44 +0200
Message-ID: <4BD8452C.7040305@free.fr>
References: <1272034539-19899-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.17.164]:42933 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754637Ab0D1OYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 10:24:46 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.1/8.13.1) with ESMTP id o3SEOjs4002058
	for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 14:24:45 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3SEOjlo1716454
	for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 16:24:45 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o3SEOiIs029390
	for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 16:24:45 +0200
In-Reply-To: <1272034539-19899-1-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Smith wrote:
> This set extends the existing network socket, device, and namespace support
> in the checkpoint tree to cover routing information.  It does so by making
> heavy use of RTNETLINK to dump and insert routes much like userspace would.
> Because the task doing the checkpointing or restarting needs to examine
> or setup resources for tasks in network namespaces other than its own, an
> additional kernel socket setup call is added.  It provides us the ability
> to talk to RTNETLINK in a foreign netns.
>
> The support added in this set allows me to configure various inet4 and inet6
> routes in a container and have them saved and restored successfully during
> a checkpoint/restart process.
>   

Why do you need to do that from the kernel ? Same remark for ipv4/6 
addresses.
What prevents you to do 'ip route show'  and use these informations to 
restore the routes later ?
Will we end up by moving all the network userspace tools in the kernel ? :)

If you use the Eric's setns patchset, you will be able to do that easily 
from userspace, no ?


