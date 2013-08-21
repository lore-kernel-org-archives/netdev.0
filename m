From: Kay Sievers <kay-tD+1rO4QERM@public.gmane.org>
Subject: Re: [systemd-devel] [PATCH] netns: unix: only allow to find out unix
	socket in same net namespace
Date: Wed, 21 Aug 2013 11:51:53 +0200
Message-ID: <CAPXgP120YUEVnFiD0uPnqeO4x=5oRvHL79-cX5CnmEWc3d5mvQ@mail.gmail.com>
References: <1377059473-25526-1-git-send-email-gaofeng@cn.fujitsu.com>
	<87d2p7vcdx.fsf@xmission.com> <5214641C.9030902@cn.fujitsu.com>
	<87wqnfttdf.fsf@xmission.com> <52146AC2.5070409@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
	"libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <52146AC2.5070409-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

On Wed, Aug 21, 2013 at 9:22 AM, Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> On 08/21/2013 03:06 PM, Eric W. Biederman wrote:

>> I suspect libvirt should simply not share /run or any other normally
>> writable directory with the host.  Sharing /run /var/run or even /tmp
>> seems extremely dubious if you want some kind of containment, and
>> without strange things spilling through.

Right, /run or /var cannot be shared. It's not only about sockets,
many other things will also go really wrong that way.

> right now I only take note of the unix socket /run/systemd/private,
> but there may have many similar unix sockets, they can exist in any
> path. the strange problems will still happen.
>
> anyway, I will send a patch to setup a fresh tmpfs for the /run directory of
> container first.

This is what systemd-nspawn does for a container setup:
  http://cgit.freedesktop.org/systemd/systemd/tree/src/nspawn/nspawn.c#n350

Kay
