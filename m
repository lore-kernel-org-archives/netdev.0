From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH nf-next] netfilter: xtables: lightweight process control
 group matching
Date: Tue, 22 Oct 2013 09:42:13 +0200
Message-ID: <52662C55.9020701@redhat.com>
References: <1380910855-12325-1-git-send-email-dborkman@redhat.com> <87li1qp3l8.fsf@xmission.com> <526231E0.6060903@redhat.com> <526543A2.2040901@monom.org> <52654CE6.7030706@redhat.com> <91E2D863603AD4478F101CE81E76E45D01828D59@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Wagner <wagi@monom.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>
To: "Ni, Xun" <xun.ni@intel.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <91E2D863603AD4478F101CE81E76E45D01828D59@SHSMSX103.ccr.corp.intel.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/22/2013 09:15 AM, Ni, Xun wrote:
> Hello, Daniel:
>     can all your examples block early before doing network operations? What's the whole netfilter universe? Can you give us more clear examples?

As you can see from the code, the netfilter hooks are located
in NF_INET_LOCAL_OUT and NF_INET_POST_ROUTING.

> Thanks
> On 10/21/2013 05:09 PM, Daniel Wagner wrote:
>> On 10/19/2013 08:16 AM, Daniel Borkmann wrote:
>>> On 10/19/2013 01:21 AM, Eric W. Biederman wrote:
>>>
>>>> I am coming to this late.  But two concrete suggestions.
>>>>
>>>> 1) process groups and sessions don't change as frequently as pids.
>>>>
>>>> 2) It is possible to put a set of processes in their own network
>>>>      namespace and pipe just the packets you want those processes to
>>>>      use into that network namespace.  Using an ingress queueing filter
>>>>      makes that process very efficient even if you have to filter by port.
>>>
>>> Actually in our case we're filtering outgoing traffic, based on which
>>> local socket that originated from; so you wouldn't need all of that
>>> construct. Also, you wouldn't even need to have an a-prio knowledge
>>> of the application internals regarding their use of particular use of
>>> ports or protocols. I don't think that such a setup will have the
>>> same efficiency, ease of use, and power to distinguish the
>>> application the traffic came from in such a lightweight, protocol independent and easy way.
>>
>> Sorry for beeing late as well (and also stupid question)
>>
>> Couldn't you use something from the LSM? I mean you allow the
>> application to create the socket etc and then block later the traffic
>> originated from that socket. Wouldn't it make more sense to block
>> early?
>
> I gave one simple example for blocking in the commit message, that's true, but it is not limited to that, meaning we can have much different scenarios/policies that netfilter allows us than just blocking, e.g. fine grained settings where applications are allowed to connect/send traffic to, application traffic marking/ conntracking, application-specific packet mangling, and so on, just think of the whole netfilter universe.
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
