From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal firewalls"
Date: Tue, 20 Jan 2009 17:18:04 -0800
Message-ID: <497677CC.105@schaufler-ca.com>
References: <317242.47729.qm@web31508.mail.mud.yahoo.com> <m28wp532dz.fsf@ssh.synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: imipak@yahoo.com,
	linux-security-module <linux-security-module@vger.kernel.org>,
	Stephan Peijnik <stephan@peijnik.at>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Samir Bellabes <sam@synack.fr>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <m28wp532dz.fsf@ssh.synack.fr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Samir Bellabes wrote:
> Jonathan Day <imipak@yahoo.com> writes:
>
>   
>> --- On Tue, 1/20/09, Stephan Peijnik <stephan@peijnik.at> wrote:
>>     
>
> [...]
>
>   
>>> This means personal firewalls should not enforce system
>>> security policy,
>>> but rather a per-user security policy.
>>> The implementations can then add caching of decisions made
>>> (ie.
>>> "remember this decision") and thus not ask every
>>> time a call is made.
>>> Also, the only protocols to be supported are IPv4 and IPv6.
>>> Adding
>>> support for AF_UNIX and/or AF_NETLINK doesn't make much
>>> sense, as this
>>> is not network-related and would only increase the amount
>>> of work a
>>> personal firewall implementation has to do.
>>>       
>> I agree that Unix and Netlink would not be useful, but there are other socket types that are LAN- or WAN-based, and I'd not be too quick to implement anything that precluded them being covered. (There's a difference between designing code in a way that makes extending it hard and actually implementing other network types, so only implementing IPv4 and IPv6 on a framework that could be extended by anyone deeply passionate about other protocls makes sense -- unless implementing it that way would be so much harder that it's pointless.)
>>     
>
> Exactly, and the cost for the kernel subsystem and the userspace low
> level part should only be adding the new elements for sending usefull
> informations to the userspace and wait for verdict, but the cost for the
> 'personnal firewall' developper is higher (how this protocol is
> interacting with others ? etc etc)
>
>   
>>> All proposed implementations of personal firewalls until
>>> now have made
>>> it rather clear that the decision-making logic should be
>>> placed in
>>> userspace, whilst only a small piece of code communicating
>>> with a
>>> userspace daemon should be placed in the kernel itself.
>>>       
>> Well, it has probably not been a significant factor in anyone's decision, but it occurs to me that per-process firewalling within the kernel makes the "per-process" bit much more complicated and would not work at all using any of the zerocopy or kernel bypass networking mechanisms.
>>     
>
> we don't need this at all, as we are in process context, syscall can
> sleep.
> Trust me, it's strange to have it's web browser freezing waiting for a
> timeout if the userspace part doesn't reply, but if it's replying, it's
> transparent.

I hate to be the one to say this, but it looks to me as if the
easiest way to solve the problems that you have outlined would
be to create a new LSM based on SELinux with two important
changes. The first would be to have a separate policy for each
user (or process tree) and the second would be to make the policy
specification discretionary. SELinux has all the mechanism you're
talking about, but you want the policy being enforced to reflect
a set of "personal firewall" rules rather than "domain type" rules.
 From the lobby at LCA in Hobart these rule sets are pretty hard to
tell apart. And let's not have the "SELinux isn't designed to do
that" row. Of course it isn't. Nonetheless, the personal firewall
sure sounds a lot like SELinux if you ignore the MAC/DAC difference.


