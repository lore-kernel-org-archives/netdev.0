From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Fri, 03 Aug 2012 18:34:48 -0700
Message-ID: <1d3bddff-4b3a-4ed1-b8f9-21bd531ba20b@email.android.com>
References: <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com> <87boitz044.fsf@xmission.com> <501C3527.6060809@mellanox.com> <20120803.143315.151094375569109262.davem@davemloft.net> <501C5328.4060301@mellanox.com> <501C669B.2030303@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: ogerlitz@mellanox.com, roland@kernel.org, netdev@vger.kernel.org,
	sean.hefty@intel.com, erezsh@mellanox.co.il
To: Ali Ayoub <ali@mellanox.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58162 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753166Ab2HDBfC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 21:35:02 -0400
In-Reply-To: <501C669B.2030303@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ali Ayoub <ali@mellanox.com> wrote:

>
>With this driver, existing VMs, and their existing IP applications, can
>run as-is on InfiniBand network.

Actually it doesn't work like that.

If my application really needs ethernet it will not work with your driver.  I can not run decnet or appletalk or ATAoE or PPPoE or LACP or use VLANs or any of a thousand other things that require real live ethernet to function.

Most VMs will talk to linux with a tap interface, and the output of a tap interface can be routed just fine, and that works with existing tools, and existing already deployed  kernels.

Alternatively if you are silly you can implement a tap interface on top of IPoIB and have the same interface you do now, and it works with existing already deployed kernels.

So eIPoIB does not make sense from a time to market perspective.

Similarly eIPoIB does not make sense from a performance standpoint because the best performance requires the applications and hypervisors are infiniband and teaching the apps to cope.

eIPoIB also has considerable maintenance overhead as it is complex code doing some crazy things.

Now personally NAPT44 just about made the internet unusable for peer to peer appications.  NAT66 aka network prefix translation introduces much less breakage but it still requires someone to run STUN on IPv6 to keep applications working, ick.  NATEIB aka eIPoIB just looks complex and already breaks most of ethernet and history says that kind of breakage actually matters a lot.   I think everyone who suggests any kind of NAT is a good idea should have to implement RFC 5245 Interacive Connectivity Establishment.  It takes 2 100+ page rfcs to come up with a way that  allows applications to with the address munging over the open internet.   That way takes 3000+ lines of code in each application.   That is the kind of complexity you are asking people up stream of you to deal with your NATTing o
 f ethernet to infiniband.  So I totally think eIPoIB stinks, and that it does not at all let existing applications work without modification.

Eric
