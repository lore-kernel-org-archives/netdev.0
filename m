From: Howard Chu <hyc@symas.com>
Subject: Re: TCP 2MSL on loopback
Date: Tue, 06 Mar 2007 14:07:09 -0800
Message-ID: <45EDE60D.1030706@symas.com>
References: <45EDD17F.5000203@cosmosbay.com>	<45EDD791.4040908@symas.com>	<45EDDC4F.7010201@hp.com> <20070306.133516.104036428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, dada1@cosmosbay.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from highlandsun.propagation.net ([66.221.212.168]:2351 "EHLO
	highlandsun.propagation.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030370AbXCFWM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 17:12:56 -0500
In-Reply-To: <20070306.133516.104036428.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Tue, 06 Mar 2007 13:25:35 -0800
> 
>>> On the other hand, being able to configure a small MSL for the loopback 
>>> device is perfectly safe. Being able to configure a small MSL for other 
>>> interfaces may be safe, depending on the rest of the network layout.
>> A peanut gallery question - I seem to recall prior discussions about how 
>> one cannot assume that a packet destined for a given IP address will 
>> remain detined for that given IP address as it could go through a module 
>> that will rewrite headers etc.
> 
> That's right, both netfilter and the packet scheduler actions
> can do that, that's why this whole idea about changing the MSL
> on loopback by default is wrong and pointless.

If the headers get rewritten and the packet gets directed elsewhere, 
then we're no longer talking about a loopback connection, so that's 
outside the discussion.

If the packet gets munged by multiple filters but still eventually gets 
to the specified destination, OK. But regardless, if both endpoints of 
the connection are on the loopback device, then there is nothing wrong 
with the idea. Those filters can only do so much, they still have to 
preserve the reliable in-order delivery semantics of TCP, otherwise the 
system is broken.

It may not have much use, sure, I admitted that much from the outset.

So I'll leave it at this, thanks for the feedback.
-- 
   -- Howard Chu
   Chief Architect, Symas Corp.  http://www.symas.com
   Director, Highland Sun        http://highlandsun.com/hyc
   Chief Architect, OpenLDAP     http://www.openldap.org/project/
