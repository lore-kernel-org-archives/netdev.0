From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 1/2] netns: fix NULL-dereference in dev_net()
Date: Sat, 16 Aug 2008 23:30:09 +0200
Message-ID: <48A746E1.90703@fr.ibm.com>
References: <48A4871D.1030708@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	containers <containers@lists.osdl.org>, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:23781 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500AbYHPVa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2008 17:30:26 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id m7GLUF6N093744
	for <netdev@vger.kernel.org>; Sat, 16 Aug 2008 21:30:15 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7GLUFXP3829928
	for <netdev@vger.kernel.org>; Sat, 16 Aug 2008 23:30:15 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7GLUEKl015401
	for <netdev@vger.kernel.org>; Sat, 16 Aug 2008 23:30:15 +0200
In-Reply-To: <48A4871D.1030708@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley wrote:
> Change dev_net() to handle a NULL argument - return &init_net instead.
> 
> -Brian
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Did you fall into the case where the argument was NULL ?

If it is the case, I think it is not the proper way to handle that. 
IMHO, this is the symptom the code which calls this function has a 
problem with the network namespace and it should be changed to be 
correct. eg, the code is assuming the network device is never null and 
so the network namespace can be retrieved from it, a correct fix may be 
to pass the network namespace as parameter of the function.

Returning &init_net if the network device is null will gracefully avoid 
the kernel oopsing but will lead to some inconsistent behaviour and 
confusion with what is happening with the namespace.

IMO, we should be radical and let the kernel oopsing, giving us only one 
action which is to fix asap the bug correctly.

Thanks.
   -- Daniel
