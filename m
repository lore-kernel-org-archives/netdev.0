From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH net-next] [RFC] netns: enable cross-ve Unix sockets
Date: Wed, 01 Oct 2008 15:08:07 +0200
Message-ID: <48E37637.8080408@fr.ibm.com>
References: <1222858454-7843-1-git-send-email-den@openvz.org>	<48E35B4C.1040303@fr.ibm.com>	<1222860776.23573.49.camel@iris.sw.ru>	<48E3653C.1070701@fr.ibm.com>	<1222862583.23573.54.camel@iris.sw.ru>	<48E36ABF.8030908@fr.ibm.com> <48E36BFA.3040904@openvz.org>	<48E36DA0.9080400@fr.ibm.com> <48E36FDA.5090808@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, Denis Lunev <den@openvz.org>,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	ebiederm@xmission.com, benjamin.thery@bull.net
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:36381 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789AbYJANIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 09:08:16 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id m91D8Eof034304
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 13:08:14 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m91D8ED73604512
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 15:08:14 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m91D8A5D029111
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 15:08:11 +0200
In-Reply-To: <48E36FDA.5090808@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> Daniel Lezcano wrote:
>> Pavel Emelyanov wrote:
>>>> So there are 2 cases:
>>>>   * full isolation : restriction on VPS
>>>>   * partial isolation : no restriction but *perhaps* problem when migrating
>>>>
>>>> Looks like we need an option per namespace to reduce the isolation for 
>>>> af_unix sockets :)
>>>>   - on (default): current behaviour => full isolation
>>>>   - off : partial isolation
>>> You mean some sysctl, that enables/disables this check in unix_find_socket_byinode?
>> Yes.
> 
> OK. Den, please, do :)

hmm, would that allow sibling namespaces to connect to each other ? If so, 
I'm not in favor of such a solution. 

I understand the need. we had a similar issue with the command line tool 
pgsl. Could we work something out with the capabilities ? or make an 
exception if your ->nsproxy->net_ns == init_net ? 

Thanks,

C.  
