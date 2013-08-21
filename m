From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] netns: unix: only allow to find out unix socket in same
 net namespace
Date: Wed, 21 Aug 2013 15:22:42 +0800
Message-ID: <52146AC2.5070409@cn.fujitsu.com>
References: <1377059473-25526-1-git-send-email-gaofeng@cn.fujitsu.com> <87d2p7vcdx.fsf@xmission.com> <5214641C.9030902@cn.fujitsu.com> <87wqnfttdf.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, systemd-devel@lists.freedesktop.org,
	lxc-devel@lists.sourceforge.net, davem@davemloft.net,
	Linux Containers <containers@lists.linux-foundation.org>,
	"libvir-list@redhat.com" <libvir-list@redhat.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:15510 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752221Ab3HUHVY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 03:21:24 -0400
In-Reply-To: <87wqnfttdf.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/2013 03:06 PM, Eric W. Biederman wrote:
> Gao feng <gaofeng@cn.fujitsu.com> writes:
> 
>> cc libvirt-list
>>
>> On 08/21/2013 01:30 PM, Eric W. Biederman wrote:
>>> Gao feng <gaofeng@cn.fujitsu.com> writes:
>>>
>>>> Unix sockets are private resources of net namespace,
>>>> allowing one net namespace to access to other netns's unix
>>>> sockets is meaningless.
>>>
>>> Allowing one net namespace to access another netns's unix socket is
>>> deliberate behavior.  This is a desired and useful feature, and
>>> only a misconfiguration of visible files would allow this to be a
>>> problem.
>>>
>>>> I'm researching a problem about shutdown from container,
>>>> if the cotainer shares the same file /run/systemd/private
>>>> with host, when we run shutdown -h xxx in container, the
>>>> shutdown message will be send to the systemd-shutdownd
>>>> through unix socket /run/systemd/private, and because
>>>> systemd-shutdownd is running in host, so finally, the host
>>>> will become shutdown.
>>>
>>> The simple answer is don't do that then.  I can see no reason
>>> to share /run outside of the container unless you want this kind of
>>> behavior.
>>>
>>> Quite frankly I want this behavior if I am using network namespaces
>>> to support multiple routing contexts. That is if I am using scripts
>>> like:
>>>
>>> ip netns add other
>>> ip netns exec other script
>>>
>>> I don't want to have to remember to say 
>>> ip netns orig exec shutdown -h now
>>>
>>> There are more compelling uses and there is no cost in supporting this
>>> in the kernel.
>>>
>>> What kind of misconfiguration caused someone to complain about this?
>>>
>>
>> libvirt lxc allows user to set up a container which shares the same root
>> directory with host.
>>
>> seems like the unix sockets whose sun_path is an abstract socket address
>> are net namespace aware.
>>
>> Should we use "abstract" type of address instead of a file system pathname
>> for systemd in this case?
> 
> I suspect libvirt should simply not share /run or any other normally
> writable directory with the host.  Sharing /run /var/run or even /tmp
> seems extremely dubious if you want some kind of containment, and
> without strange things spilling through.
> 

right now I only take note of the unix socket /run/systemd/private,
but there may have many similar unix sockets, they can exist in any
path. the strange problems will still happen.

anyway, I will send a patch to setup a fresh tmpfs for the /run directory of
container first.

Eric, Thanks for your help!
