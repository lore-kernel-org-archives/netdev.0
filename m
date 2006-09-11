From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [Devel] Re: [RFC] network namespaces
Date: Mon, 11 Sep 2006 16:40:59 +0200
Message-ID: <4505757B.3020004@fr.ibm.com>
References: <20060815182029.A1685@castle.nmd.msu.ru>	<200609081710.09124.dim@openvz.org>	<20060908181154.GA8745@MAIL.13thfloor.at> <200609091157.24734.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Poetzl <herbert@13thfloor.at>,
	Kir Kolyshkin <kir@openvz.org>, Andrey Savochkin <saw@sw.ru>,
	netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>, alexey@sw.ru,
	sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:59918 "EHLO
	mtagate4.de.ibm.com") by vger.kernel.org with ESMTP id S932227AbWIKOlA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 10:41:00 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id k8BEexWB180994
	for <netdev@vger.kernel.org>; Mon, 11 Sep 2006 14:40:59 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8BEjVD43231938
	for <netdev@vger.kernel.org>; Mon, 11 Sep 2006 16:45:31 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8BEewvI007753
	for <netdev@vger.kernel.org>; Mon, 11 Sep 2006 16:40:58 +0200
To: Dmitry Mishin <dim@openvz.org>
In-Reply-To: <200609091157.24734.dim@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry Mishin wrote:
> On Friday 08 September 2006 22:11, Herbert Poetzl wrote:
> 
>>actually the light-weight ip isolation runs perfectly
>>fine _without_ CAP_NET_ADMIN, as you do not want the
>>guest to be able to mess with the 'configured' ips at
>>all (not to speak of interfaces here)
> 
> It was only an example. I'm thinking about how to implement flexible solution, 
> which permits light-weight ip isolation as well as full-fledged netwrok 
> virtualization. Another solution is to split CONFIG_NET_NAMESPACE. Is it good 
> for you?

Hi Dmitry,

I am currently working on this and I am finishing a prototype bringing 
isolation at the ip layer. The prototype code is very closed to Andrey's 
patches at TCP/UDP level. So the next step is to merge the prototype 
code with the existing network namespace layer 2 isolation.

IHMO, the solution of spliting CONFIG_NET_NS into CONFIG_L2_NET_NS and 
CONFIG_L3_NET_NS is for me not acceptable because you will need to 
recompile the kernel. The proper way is certainly to have a specific 
flag for the unshare, something like CLONE_NEW_L2_NET and 
CLONE_NEW_L3_NET for example.

   -- Daniel

