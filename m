From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] netns: unix: only allow to find out unix socket in same
	net namespace
Date: Wed, 21 Aug 2013 00:06:52 -0700
Message-ID: <87wqnfttdf.fsf@xmission.com>
References: <1377059473-25526-1-git-send-email-gaofeng@cn.fujitsu.com>
	<87d2p7vcdx.fsf@xmission.com> <5214641C.9030902@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
	"libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5214641C.9030902-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> (Gao feng's message of "Wed, 21
	Aug 2013 14:54:20 +0800")
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

Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:

> cc libvirt-list
>
> On 08/21/2013 01:30 PM, Eric W. Biederman wrote:
>> Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
>> 
>>> Unix sockets are private resources of net namespace,
>>> allowing one net namespace to access to other netns's unix
>>> sockets is meaningless.
>> 
>> Allowing one net namespace to access another netns's unix socket is
>> deliberate behavior.  This is a desired and useful feature, and
>> only a misconfiguration of visible files would allow this to be a
>> problem.
>> 
>>> I'm researching a problem about shutdown from container,
>>> if the cotainer shares the same file /run/systemd/private
>>> with host, when we run shutdown -h xxx in container, the
>>> shutdown message will be send to the systemd-shutdownd
>>> through unix socket /run/systemd/private, and because
>>> systemd-shutdownd is running in host, so finally, the host
>>> will become shutdown.
>> 
>> The simple answer is don't do that then.  I can see no reason
>> to share /run outside of the container unless you want this kind of
>> behavior.
>> 
>> Quite frankly I want this behavior if I am using network namespaces
>> to support multiple routing contexts. That is if I am using scripts
>> like:
>> 
>> ip netns add other
>> ip netns exec other script
>> 
>> I don't want to have to remember to say 
>> ip netns orig exec shutdown -h now
>> 
>> There are more compelling uses and there is no cost in supporting this
>> in the kernel.
>> 
>> What kind of misconfiguration caused someone to complain about this?
>> 
>
> libvirt lxc allows user to set up a container which shares the same root
> directory with host.
>
> seems like the unix sockets whose sun_path is an abstract socket address
> are net namespace aware.
>
> Should we use "abstract" type of address instead of a file system pathname
> for systemd in this case?

I suspect libvirt should simply not share /run or any other normally
writable directory with the host.  Sharing /run /var/run or even /tmp
seems extremely dubious if you want some kind of containment, and
without strange things spilling through.

Eric
