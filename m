From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH][NETNS] Make ifindex generation per-namespace
Date: Tue, 09 Oct 2007 16:48:16 +0200
Message-ID: <470B94B0.6060504@fr.ibm.com>
References: <470B71CD.3000706@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:36474 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753746AbXJIOyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 10:54:35 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id l99EsY8t754192
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 14:54:34 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l99EsXxj2322508
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 16:54:33 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l99EsXwx013093
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 16:54:33 +0200
In-Reply-To: <470B71CD.3000706@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov wrote:
> Currently indexes for netdevices come sequentially one by
> one, and the same stays true even for devices that are 
> created for namespaces.
> 
> Side effects of this are:
>  * lo device has not 1 index in a namespace. This may break
>    some userspace that relies on it (and AFAIR something
>    really broke in OpenVZ VEs without this);
>  * after some time namespaces will have devices with indexes
>    like 1000000 os similar. This might be confusing for a
>    human (tools will not mind).
> 
> So move the (currently "global" and static) ifindex variable
> on the struct net, making the indexes allocation look more
> like on a standalone machine.
> 
> Moreover - when we have indexes intersect between namespaces,
> we may catch more BUGs in the future related to "wrong device 
> was found for a given index".
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied and tested against netns49. Works fine.

Acked-by: Daniel Lezcano <dlezcano@fr.ibm.com>

