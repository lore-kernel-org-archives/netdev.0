From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [net-next RFC v2] net_cls: traffic counter based on classification
 control cgroup
Date: Wed, 28 Nov 2012 09:09:15 +0100
Message-ID: <50B5C6AB.6040208@monom.org>
References: <50B49C6C.8030604@samsung.com> <50B49DEA.7010000@parallels.com> <50B4B9E2.4030200@monom.org> <50B59F54.8080401@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexey Perevalov <a.perevalov-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <50B59F54.8080401-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Alexey,

On 28.11.2012 06:21, Alexey Perevalov wrote:
>>> Daniel Wagner is working on something a lot similar.
>> Yes, basically what I try to do is explained by this excellent article
>>
>> https://lwn.net/Articles/523058/
> I read articles and agreed with aspects.
> But problem of selecting preferred network for application can be solved 
> using netprio cgroup.

Choosing the which network to connect to is job of a connection manager.
I don't see how a cgroup controller can help you there. I guess I do not 
understand your statement. Can you rephrase please?

>> The second implementation is adding a new iptables matcher which matches
>> on LSM contexts. Then you can do something like this:
>>
>> iptables -t mangle -A OUTPUT -m secmark --secctx 
>> unconfined_u:unconfined_r:foo_t:s0-s0:c0.c1023 -j MARK --set-mark 200
> As I understand in LSM context it works for egress and ingress.

Yes, I am using CONNMARK in conjunction with the the above LSM context
matcher. I am still playing around, but it looks quite promising.

>>> 2) When Daniel exposed his use case to me, it gave me the impression
>>> that "counting traffic" is something that is totally doable by having a
>>> dedicated interface in a separate namespace. Basically, we already count
>>> traffic (rx and tx) for all interfaces anyway, so it suggests that it
>>> could be an interesting way to see the problem.
>> Moving applications into separate net namespaces is for sure a valid 
>> solution.
>> Though there is a one drawback in this approach. The namespaces need 
>> to be
>> attached to a bridge and then some NATting. That means every application
>> would get it's own IP address. This might be okay for your certain use
>> cases but I am still trying to work around this. Glauber and I had some
>> discussion about this and he suggested to allow the physical networking
>> device to be attached to several namespaces (e.g. via macvlan). Every
>> namespace would get the same IP address. Unfortunately, this would 
>> result in
>> the same mess as several physical devices on a network get the same
>> IP address assigned.
> Is I truly understand what to make statistics works we need to put 
> process to separate namespace?

If a process lives in its own network namespace then you can
count the packets/bytes on the network interface level. The side effect
is that is that each namespace is obviously a new network and has to be
treated as such.

> Approach to keep counter in cgroup hasn't such side effects, but it has 
> another ).

cgroups are not for free. Currently a lot of effort is put into getting
a reasonable performance and behavior into cgroups. In this situation
any new feature added to cgroups will need a pretty good justification
why it is needed and why it cant be done with existing infrastructure.

Here is some background information on the state of cgroups:

http://thread.gmane.org/gmane.linux.kernel.containers/23698

cheers,
daniel
