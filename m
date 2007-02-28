From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH RFC 18/31] net: Implment network device movement between
 namespaces
Date: Wed, 28 Feb 2007 15:35:41 +0100
Message-ID: <45E5933D.4070304@fr.ibm.com>
References: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com> <11697516372179-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	openib-general@openib.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:41310 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932878AbXB1Oft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 09:35:49 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id l1SEZmJT077114
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 14:35:48 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1SEZlKG2060528
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 15:35:47 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1SEZl8F012630
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 15:35:47 +0100
In-Reply-To: <11697516372179-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> From: Eric W. Biederman <ebiederm@xmission.com> - unquoted
>
> This patch introduces NETIF_F_NETNS_LOCAL a flag to indicate
> a network device is local to a single network namespace and
> should never be moved.  Useful for pseudo devices that we
> need an instance in each network namespace (like the loopback
> device) and for any device we find that cannot handle multiple
> network namespaces so we may trap them in the initial network
> namespace.
>
> This patch introduces the function dev_change_net_namespace
> a function used to move a network device from one network
> namespace to another.  To the network device nothing
> special appears to happen, to the components of the network
> stack it appears as if the network device was unregistered
> in the network namespace it is in, and a new device
> was registered in the network namespace the device
> was moved to.
>
> This patch sets up a namespace device destructor that
> upon the exit of a network namespace moves all of the
> movable network devices  to the initial network namespace
> so they are not lost.
>   
If you:
 * create etun0/etun1
 * create a namespace
 * move etun1 to this namespace
 *  rename the etun1 to eth0
 *  kill the namespace

the former network device etun1 will be lost if you have in your parent 
namespace an interface eth0 because it will conflict.
Perhaps, the first name should be restored before moving the device back 
to the initial network namespace ?

  -- Daniel

ps : nice patchset
