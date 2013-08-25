From: Kay Sievers <kay-tD+1rO4QERM@public.gmane.org>
Subject: Re: [systemd-devel] [PATCH] netns: unix: only allow to find out unix
	socket in same net namespace
Date: Sun, 25 Aug 2013 19:37:14 +0200
Message-ID: <CAPXgP115pEE8jxyCqauoMRWui3Qb0fBzPr9L2_SA411=gfnX3w@mail.gmail.com>
References: <1377059473-25526-1-git-send-email-gaofeng@cn.fujitsu.com>
	<87d2p7vcdx.fsf@xmission.com> <5214641C.9030902@cn.fujitsu.com>
	<87wqnfttdf.fsf@xmission.com> <52146AC2.5070409@cn.fujitsu.com>
	<CAPXgP120YUEVnFiD0uPnqeO4x=5oRvHL79-cX5CnmEWc3d5mvQ@mail.gmail.com>
	<1377450974.8757.41.camel@dabdike>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org"
	<systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>,
	"libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org" <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1377450974.8757.41.camel@dabdike>
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

On Sun, Aug 25, 2013 at 7:16 PM, James Bottomley
<jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:
> On Wed, 2013-08-21 at 11:51 +0200, Kay Sievers wrote:
>> On Wed, Aug 21, 2013 at 9:22 AM, Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>> > On 08/21/2013 03:06 PM, Eric W. Biederman wrote:
>>
>> >> I suspect libvirt should simply not share /run or any other normally
>> >> writable directory with the host.  Sharing /run /var/run or even /tmp
>> >> seems extremely dubious if you want some kind of containment, and
>> >> without strange things spilling through.
>>
>> Right, /run or /var cannot be shared. It's not only about sockets,
>> many other things will also go really wrong that way.
>
> This is very narrow thinking about what a container might be and will
> cause trouble as people start to create novel uses for containers in the
> cloud if you try to impose this on our current infrastructure.
>
> One of the cgroup only container uses we see at Parallels (so no
> separate filesystem and no net namespaces) is pure apache load balancer
> type shared hosting.  In this scenario, base apache is effectively
> brought up in the host environment, but then spawned instances are
> resource limited using cgroups according to what the customer has paid.
> Obviously all apache instances are sharing /var and /run from the host
> (mostly for logging and pid storage and static pages).  The reason some
> hosters do this is that it allows much higher density simple web serving
> (either static pages from quota limited chroots or dynamic pages limited
> by database space constraints) because each "instance" shares so much
> from the host.  The service is obviously much more basic than giving
> each customer a container running apache, but it's much easier for the
> hoster to administer and it serves the customer just as well for a large
> cross section of use cases and for those it doesn't serve, the hoster
> usually has separate container hosting (for a higher price, of course).

The "container" as we talk about has it's own init, and no, it cannot
share /var or /run.

The stuff you talk about has nothing to do with that, it's not
different from all services or a multi-instantiated service on the
host sharing the same /run and /var.

Kay
