From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] netlink broadcast return value
Date: Tue, 10 Feb 2009 14:50:55 +0100
Message-ID: <4991863F.3030800@trash.net>
References: <4985A4C5.4050908@netfilter.org> <20090202.140533.121159038.davem@davemloft.net> <49903B03.2040302@trash.net> <4990B38A.3020207@netfilter.org> <4990BADA.7040309@trash.net> <4990C337.3040704@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4990C337.3040704@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso wrote:
> Patrick McHardy wrote:
>> Pablo Neira Ayuso wrote:
> 
>> But unless I'm missing something, there's nothing wrong with this
>> as long as the error is ignored. The fact that something was received
>> by some listener doesn't have any meaning anyways, it might have
>> been "ip monitor". Which somehow raises doubt about your proposed
>> interface change though, I think anything that wants a reliable
>> answer whether a packet was delivered to a process handling it
>> appropriately should use unicast.
> 
> Don't get me wrong, I agree with you that all netlink_broadcast callers
> in the kernel should ignore the return value...
> 
> ... unless they have "some way" (like in Netfilter) to make event
> delivery reliable: I have attached a patch that I didn't send you yet,
> I'm still reviewing and testing it. It adds an entry to /proc to enable
> reliable event delivery over netlink by dropping packets whose events
> were not delivered, you mentioned that possibility once during one of
> our conversations ;).

I know, but in the mean time I think its wrong :) The delivery
isn't reliable and what the admin is effectively expressing by
setting your sysctl is "I don't have any listeners besides the
synchronization daemon running". So it might as well use unicast.

> I'm aware of that this option may be dangerous if used by a buggy
> process that trigger frequent overflows but it the cost of having
> realible logging for ctnetlink (still, this behaviour is not the one by
> default!).
> 
> And I need this option to make conntrackd synchronize state-changes
> appropriately under very heavy load: I've testing the daemon with these
> patches and it reliably synchronizes state-changes (my system were 100%
> busy filtering traffic and fully synchronizing all TCP state-changes in
> near real-time effort, with a noticeable performance drop of 30% in
> terms of filtered connections).

So you're dropping the packet if you can't manage to synchronize.
Doesn't that defeat the entire purpose of synchronizing, which is
*increasing* reliability? :)
