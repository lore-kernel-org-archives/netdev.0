From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Traffic control cgroups subsystem
Date: Tue, 22 Jul 2008 12:35:09 +0200
Message-ID: <4885B7DD.7070507@trash.net>
References: <Pine.LNX.4.64.0807212100580.1760@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lizf@cn.fujitsu.com, menage@google.com
To: Ranjit Manomohan <ranjitm@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58038 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820AbYGVKfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 06:35:13 -0400
In-Reply-To: <Pine.LNX.4.64.0807212100580.1760@ranjit.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ranjit Manomohan wrote:
> 
> [Take 2] - Incorporated comments from Patric McHardy & Li Zefan.
> 
> This patch provides a simple resource controller (cgroup_tc) based on the
> cgroups infrastructure to manage network traffic. The cgroup_tc resource
> controller can be used to schedule and shape traffic belonging to the 
> task(s)
> in a particular cgroup.
> 
> The implementation consists of two parts:
> 
> 1) A resource controller (cgroup_tc) that is used to associate packets from
>    a particular task belonging to a cgroup with a traffic control class 
> id (
>    tc_classid). This tc_classid is propagated to all sockets created by 
> tasks
>    in the cgroup and from there to all packets associated with those 
> sockets.
> 
> 2) A modified traffic control classifier (cls_flow) that can classify 
> packets
>    based on the tc_classid field in the packet to specific destination 
> classes.

Does this really have to be a new skb member? You could
simply use skb->sk->sk_cgroup_classid directly, or if
that doesn't work, maybe skb->priority.
