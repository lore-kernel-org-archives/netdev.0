From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [systemd-devel] [PATCH] netns: unix: only allow to find out unix
	socket in same net namespace
Date: Mon, 26 Aug 2013 11:35:11 +0800
Message-ID: <521ACCEF.4050101@cn.fujitsu.com>
References: <1377059473-25526-1-git-send-email-gaofeng@cn.fujitsu.com>
	<87d2p7vcdx.fsf@xmission.com> <5214641C.9030902@cn.fujitsu.com>
	<87wqnfttdf.fsf@xmission.com> <52146AC2.5070409@cn.fujitsu.com>
	<CAPXgP120YUEVnFiD0uPnqeO4x=5oRvHL79-cX5CnmEWc3d5mvQ@mail.gmail.com>
	<1377450974.8757.41.camel@dabdike>
	<CAPXgP115pEE8jxyCqauoMRWui3Qb0fBzPr9L2_SA411=gfnX3w@mail.gmail.com>
	<1377454566.8757.53.camel@dabdike>
	<521AAA23.9050604@cn.fujitsu.com> <1377487159.2341.4.camel@dabdike>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org"
	<systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>,
	"libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Kay Sievers <kay-tD+1rO4QERM@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	"lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org" <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1377487159.2341.4.camel@dabdike>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/26/2013 11:19 AM, James Bottomley wrote:
> On Mon, 2013-08-26 at 09:06 +0800, Gao feng wrote:
>> On 08/26/2013 02:16 AM, James Bottomley wrote:
>>> On Sun, 2013-08-25 at 19:37 +0200, Kay Sievers wrote:
>>>> On Sun, Aug 25, 2013 at 7:16 PM, James Bottomley
>>>> <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:
>>>>> On Wed, 2013-08-21 at 11:51 +0200, Kay Sievers wrote:
>>>>>> On Wed, Aug 21, 2013 at 9:22 AM, Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>>>>>>> On 08/21/2013 03:06 PM, Eric W. Biederman wrote:
>>>>>>
>>>>>>>> I suspect libvirt should simply not share /run or any other normally
>>>>>>>> writable directory with the host.  Sharing /run /var/run or even /tmp
>>>>>>>> seems extremely dubious if you want some kind of containment, and
>>>>>>>> without strange things spilling through.
>>>>>>
>>>>>> Right, /run or /var cannot be shared. It's not only about sockets,
>>>>>> many other things will also go really wrong that way.
>>>>>
>>>>> This is very narrow thinking about what a container might be and will
>>>>> cause trouble as people start to create novel uses for containers in the
>>>>> cloud if you try to impose this on our current infrastructure.
>>>>>
>>>>> One of the cgroup only container uses we see at Parallels (so no
>>>>> separate filesystem and no net namespaces) is pure apache load balancer
>>>>> type shared hosting.  In this scenario, base apache is effectively
>>>>> brought up in the host environment, but then spawned instances are
>>>>> resource limited using cgroups according to what the customer has paid.
>>>>> Obviously all apache instances are sharing /var and /run from the host
>>>>> (mostly for logging and pid storage and static pages).  The reason some
>>>>> hosters do this is that it allows much higher density simple web serving
>>>>> (either static pages from quota limited chroots or dynamic pages limited
>>>>> by database space constraints) because each "instance" shares so much
>>>>> from the host.  The service is obviously much more basic than giving
>>>>> each customer a container running apache, but it's much easier for the
>>>>> hoster to administer and it serves the customer just as well for a large
>>>>> cross section of use cases and for those it doesn't serve, the hoster
>>>>> usually has separate container hosting (for a higher price, of course).
>>>>
>>>> The "container" as we talk about has it's own init, and no, it cannot
>>>> share /var or /run.
>>>
>>> This is what we would call an IaaS container: bringing up init and
>>> effectively a new OS inside a container is the closest containers come
>>> to being like hypervisors.  It's the most common use case of Parallels
>>> containers in the field, so I'm certainly not telling you it's a bad
>>> idea.
>>>
>>>> The stuff you talk about has nothing to do with that, it's not
>>>> different from all services or a multi-instantiated service on the
>>>> host sharing the same /run and /var.
>>>
>>> I gave you one example: a really simplistic one.  A more sophisticated
>>> example is a PaaS or SaaS container where you bring the OS up in the
>>> host but spawn a particular application into its own container (this is
>>> essentially similar to what Docker does).  Often in this case, you do
>>> add separate mount and network namespaces to make the application
>>> isolated and migrateable with its own IP address.  The reason you share
>>> init and most of the OS from the host is for elasticity and density,
>>> which are fast becoming a holy grail type quest of cloud orchestration
>>> systems: if you don't have to bring up the OS from init and you can just
>>> start the application from a C/R image (orders of magnitude smaller than
>>> a full system image) and slap on the necessary namespaces as you clone
>>> it, you have something that comes online in miliseconds which is a feat
>>> no hypervisor based virtualisation can match.
>>>
>>> I'm not saying don't pursue the IaaS case, it's definitely useful ...
>>> I'm just saying it would be a serious mistake to think that's the only
>>> use case for containers and we certainly shouldn't adjust Linux to serve
>>> only that use case.
>>>
>>
>> The feature you said above VS contianer-reboot-host bug, I prefer to
>> fix
>> the bug.
> 
> What bug?
> 
>>  and this feature can be achieved even container unshares /run
>> directory
>> with host by default, for libvirt, user can set the container
>> configuration to
>> make the container shares the /run directory with host.
>>
>> I would like to say, the reboot from container bug is more urgent and
>> need
>> to be fixed.
> 
> Are you talking about the old bug where trying to reboot an lxc
> container from within it would reboot the entire system? 

Yes, we are discussing this problem in this whole thread.

 If so, OpenVZ
> has never suffered from that problem and I thought it was fixed
> upstream.  I've not tested lxc tools, but the latest vzctl from the
> openvz website will bring up a container on the vanilla 3.9 kernel
> (provided you have USER_NS compiled in) can also be used to reboot the
> container, so I see no reason it wouldn't work for lxc as well.
> 

I'm using libvirt lxc not lxc-tools.
Not all of users enable user namespace, I trust these container management
tools can have right/proper setting which inhibit this reboot-problem occur.
but I don't think this reboot-problem won't happen in any configuration.
