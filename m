From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH 0/3] Fix Network namespace shutdown take 2
Date: Wed, 25 Feb 2009 13:43:29 +0100
Message-ID: <49A53CF1.5060503@free.fr>
References: <m1ocwxi00a.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	"Denis V. Lunev" <den@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:56556 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662AbZBYMnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 07:43:35 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.1/8.13.1) with ESMTP id n1PChX0X025035
	for <netdev@vger.kernel.org>; Wed, 25 Feb 2009 12:43:33 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n1PChWRF1581266
	for <netdev@vger.kernel.org>; Wed, 25 Feb 2009 13:43:32 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1PChWOD008238
	for <netdev@vger.kernel.org>; Wed, 25 Feb 2009 13:43:32 +0100
In-Reply-To: <m1ocwxi00a.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> 6 months ago when I introduced net_alive I fixed the symptoms
> but I failed to properly fix network namespace shutdown.
>
> I realized this when I received a bug report on Tuesday about a
> failure in icmp_send caused by packets in the arp_gueue.
>
> It turns out that the net_alive check in netif_receive_skb
> is completely unnecessary and just masked the real problem.
>
> If we remove all network devices from a network namespace before we
> shutdown network subsystems and protocols then as designed we cannot
> have packets in flight causing problems.
>
> It turns out that the root cause of these problems is that the icmp
> code was calling register_pernet_device instead of
> register_pernet_subsys and so it's cleanup was happening much too
> early.
>
> The following patchset which should work against both 2.6.29-rcX
> and net-next fixes the registration problems and removes the
> unncessary net_alive check, making the code simpler and hopefully
> more comprehensible.
>   
Hi Dave,

I don't see these patches in the net-2.6 tree. Shouldn't they be in 
net-2.6 too ?

  -- Daniel
