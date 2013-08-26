From: James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [systemd-devel] [PATCH] netns: unix: only allow to find out
	unix socket in same net namespace
Date: Mon, 26 Aug 2013 03:53:01 +0000
Message-ID: <1377489181.2341.16.camel@dabdike>
References: <1377059473-25526-1-git-send-email-gaofeng@cn.fujitsu.com>
	<87d2p7vcdx.fsf@xmission.com> <5214641C.9030902@cn.fujitsu.com>
	<87wqnfttdf.fsf@xmission.com> <52146AC2.5070409@cn.fujitsu.com>
	<CAPXgP120YUEVnFiD0uPnqeO4x=5oRvHL79-cX5CnmEWc3d5mvQ@mail.gmail.com>
	<1377450974.8757.41.camel@dabdike>
	<CAPXgP115pEE8jxyCqauoMRWui3Qb0fBzPr9L2_SA411=gfnX3w@mail.gmail.com>
	<1377454566.8757.53.camel@dabdike> <521AAA23.9050604@cn.fujitsu.com>
	<1377487159.2341.4.camel@dabdike> <521ACCEF.4050101@cn.fujitsu.com>
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
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <521ACCEF.4050101-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Content-Language: en-US
Content-ID: <0FF5E1C4A5250346A4BFA6330F04B1CC-ruSsrxOD6xDby3iVrkZq2A@public.gmane.org>
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

On Mon, 2013-08-26 at 11:35 +0800, Gao feng wrote:
> On 08/26/2013 11:19 AM, James Bottomley wrote:
> > Yes, we are discussing this problem in this whole thread.

I wasn't really watching that bit, since the problem looks solved to me.
I was just reacting against the unfortunate notion that a container
should run init.

>  If so, OpenVZ
> > has never suffered from that problem and I thought it was fixed
> > upstream.  I've not tested lxc tools, but the latest vzctl from the
> > openvz website will bring up a container on the vanilla 3.9 kernel
> > (provided you have USER_NS compiled in) can also be used to reboot the
> > container, so I see no reason it wouldn't work for lxc as well.
> > 
> 
> I'm using libvirt lxc not lxc-tools.
> Not all of users enable user namespace, I trust these container
> management
> tools can have right/proper setting which inhibit this reboot-problem
> occur.
> but I don't think this reboot-problem won't happen in any
> configuration.

It sounds like you're setting up your containers wrongly.  If a
container can reboot the system it means that host root capabilities
have leaked into the container, which is a big security no-no.  The
upstream way of avoiding this is USER_NS (because root in the container
is now not root in the host).  The OpenVZ kernel uses a different
mechanism to solve the problem, but we think USER_NS is the better way
to go on this.

James
