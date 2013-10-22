From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH nf-next] netfilter: xtables: lightweight process control
 group matching
Date: Tue, 22 Oct 2013 08:36:39 +0100
Message-ID: <52662B07.6000702@monom.org>
References: <1380910855-12325-1-git-send-email-dborkman@redhat.com> <87li1qp3l8.fsf@xmission.com> <526231E0.6060903@redhat.com> <526543A2.2040901@monom.org> <52654CE6.7030706@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52654CE6.7030706-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/21/2013 04:48 PM, Daniel Borkmann wrote:
> On 10/21/2013 05:09 PM, Daniel Wagner wrote:
>> On 10/19/2013 08:16 AM, Daniel Borkmann wrote:
>>> On 10/19/2013 01:21 AM, Eric W. Biederman wrote:
>>>
>>>> I am coming to this late.  But two concrete suggestions.
>>>>
>>>> 1) process groups and sessions don't change as frequently as pids.
>>>>
>>>> 2) It is possible to put a set of processes in their own network
>>>>     namespace and pipe just the packets you want those processes to
>>>>     use into that network namespace.  Using an ingress queueing filter
>>>>     makes that process very efficient even if you have to filter by
>>>> port.
>>>
>>> Actually in our case we're filtering outgoing traffic, based on which
>>> local socket that originated from; so you wouldn't need all of that
>>> construct. Also, you wouldn't even need to have an a-prio knowledge of
>>> the application internals regarding their use of particular use of ports
>>> or protocols. I don't think that such a setup will have the same
>>> efficiency, ease of use, and power to distinguish the application the
>>> traffic came from in such a lightweight, protocol independent and
>>> easy way.
>>
>> Sorry for beeing late as well (and also stupid question)
>>
>> Couldn't you use something from the LSM? I mean you allow the
>> application to create the socket etc and then block later
>> the traffic originated from that socket. Wouldn't it make
>> more sense to block early?
>
> I gave one simple example for blocking in the commit message,
> that's true, but it is not limited to that, meaning we can have
> much different scenarios/policies that netfilter allows us than
> just blocking, e.g. fine grained settings where applications are
> allowed to connect/send traffic to, application traffic marking/
> conntracking, application-specific packet mangling, and so on,
> just think of the whole netfilter universe.

Oh, I didn't pay enough attention to the commit message. Sorry
about that. Obviously, if fine grained settings is a must
then blocking the write is not good enough.

cheers,
daniel
