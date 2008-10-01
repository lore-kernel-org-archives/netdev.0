From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH net-next] [RFC] netns: enable cross-ve Unix sockets
Date: Wed, 01 Oct 2008 17:07:40 +0200
Message-ID: <48E3923C.5070603@fr.ibm.com>
References: <1222858454-7843-1-git-send-email-den@openvz.org>	<48E35B4C.1040303@fr.ibm.com>	<1222860776.23573.49.camel@iris.sw.ru>	<48E3653C.1070701@fr.ibm.com>	<1222862583.23573.54.camel@iris.sw.ru>	<48E36ABF.8030908@fr.ibm.com>	<48E36BFA.3040904@openvz.org>	<48E36DA0.9080400@fr.ibm.com>	<48E36FDA.5090808@openvz.org> <48E37637.8080408@fr.ibm.com> <48E3800F.1020806@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	ebiederm@xmission.com, Denis Lunev <den@openvz.org>,
	Pavel Emelyanov <xemul@openvz.org>, benjamin.thery@bull.net
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:49760 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475AbYJAPHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 11:07:48 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m91F7j4m057578
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 15:07:45 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m91F7iVD2982004
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 16:07:44 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m91F7htJ006343
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 16:07:44 +0100
In-Reply-To: <48E3800F.1020806@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano wrote:
> Cedric Le Goater wrote:
>> Pavel Emelyanov wrote:
>>> Daniel Lezcano wrote:
>>>> Pavel Emelyanov wrote:
>>>>>> So there are 2 cases:
>>>>>>   * full isolation : restriction on VPS
>>>>>>   * partial isolation : no restriction but *perhaps* problem when migrating
>>>>>>
>>>>>> Looks like we need an option per namespace to reduce the isolation for 
>>>>>> af_unix sockets :)
>>>>>>   - on (default): current behaviour => full isolation
>>>>>>   - off : partial isolation
>>>>> You mean some sysctl, that enables/disables this check in unix_find_socket_byinode?
>>>> Yes.
>>> OK. Den, please, do :)
>> hmm, would that allow sibling namespaces to connect to each other ? If so, 
>> I'm not in favor of such a solution. 
>>
>> I understand the need. we had a similar issue with the command line tool 
>> pgsl. Could we work something out with the capabilities ? or make an 
>> exception if your ->nsproxy->net_ns == init_net ? 
> 
> Why capabilities is better than a simple sysctl ?

because it depends on the current process privilege and not just some
random process.

> Making an exception for init_net will break the nested containers no ?

may be. I don't know how this is implemented. if we break isolation, my
feeling is that we should only do it for a parent namespace. It just feel 
wrong to allow sibling namespaces to connect to each other. 

C. 
