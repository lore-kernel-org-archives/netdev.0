From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [RFC] Stable interface index option
Date: Tue, 1 Dec 2015 11:11:14 -0500
Message-ID: <20151201161114.GB17843@oracle.com>
References: <20151201120420.GT12404@principal.rfc2324.org>
 <20151201153441.GA17843@oracle.com>
 <20151201155052.GA14984@principal.rfc2324.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:27901 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754496AbbLAQLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 11:11:17 -0500
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id tB1GBGXk003164
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 1 Dec 2015 16:11:16 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0022.oracle.com (8.13.8/8.13.8) with ESMTP id tB1GBG3Q011757
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 1 Dec 2015 16:11:16 GMT
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0122.oracle.com (8.13.8/8.13.8) with ESMTP id tB1GBFa9025406
	for <netdev@vger.kernel.org>; Tue, 1 Dec 2015 16:11:16 GMT
Content-Disposition: inline
In-Reply-To: <20151201155052.GA14984@principal.rfc2324.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (12/01/15 16:50), Maximilian Wilhelm wrote:
> What I have in mind is that the user can supply a list of (ifname ->
> ifindex) entries via a sysfs/procfs interface and if such a list is
> present, the kernel will search the list for every ifname which is

Having the user supply such a list is hazardous for the reason below,
esp if you consider that you can have virtual interfaces that 
take up that number.  It also allows for a sparse ifindex number
space, which can be inefficient (thus the cisco choice)

> What I'm not sure about is what to do if there is any entry in the
> list but the ifindex is already in use. One option would be to fail
> the register call because the user wanted this particular ifindex ..

If you want to do this, it's simpler to have the kernel
track 2 separate indices (the packed index and the sparse snmp-index)
per net_device. Changes to achieve it are non-trivial, of course,
and that's why I'd question how badly this is needed.

the other issue to confront is- what do you want ioctls like SIOCGIFINDEX
to return- the packed one or the sparse one? What about if_nametoindex etc?
If they return the sparse index, can they use it back with existing
ifioctl and other calls?  i.e., API compat will have some rough edges.

--Sowmini
