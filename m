From: Glauber Costa <glommer@parallels.com>
Subject: Re: [RFC] per-containers tcp buffer limitation
Date: Thu, 25 Aug 2011 15:11:37 -0300
Message-ID: <4E569059.1020606@parallels.com>
References: <4E558137.5020900@parallels.com> <m1k4a2qqew.fsf@fess.ebiederm.org> <4E55A55B.8090608@parallels.com> <20110825104956.41c4b60e.kamezawa.hiroyu@jp.fujitsu.com> <m14o16qlq1.fsf@fess.ebiederm.org> <4E56464B.4070304@monom.org> <4E5664B5.6000806@genband.com> <20110825084415.3c3094e8@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <chris.friesen@genband.com>,
	Daniel Wagner <wagi@monom.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
	Linux Containers <containers@lists.osdl.org>,
	<netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Pavel Emelyanov <xemul@parallels.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:37824 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755124Ab1HYSME (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Aug 2011 14:12:04 -0400
In-Reply-To: <20110825084415.3c3094e8@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2011 12:44 PM, Stephen Hemminger wrote:
> You seem to have forgotten the work of your forefathers. When appealing
> to history you must understand it first.
>
> What about using netfilter (with extensions)? We already have iptables
> module to match on uid or gid. It wouldn't be hard to extend this to
> other bits of meta data like originating and target containers.
>
> You could also use this to restrict access to ports and hosts on
> a per container basis.
>

Hello Stephen,

I am pretty sure netfilter can provide us with amazing functionality 
that will help our containers implementation a lot.

I don't think, however, that memory limitation belongs in there. First 
of all, IIRC, we are not dropping packets, re-routing, dealing with any
low level characteristic, etc. We're just controlling buffer size. This 
seems orthogonal to the work of netfilter.

Think for instance, in the soft limit: When we hit it, we enter a memory 
pressure scenario. How would netfilter handle that?

So I guess cgroup is still better suited for this very specific task we 
have in mind here. For most of the others, I have no doubt that 
netfilter would come handy.

Thanks for your time!
