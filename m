From: Mike Anderson <andmike@us.ibm.com>
Subject: Re: [2.6.23 PATCH 14/18] dm: netlink add to core
Date: Thu, 12 Jul 2007 10:34:10 -0700
Message-ID: <20070712173410.GA2505@us.ibm.com>
References: <20070711210159.GF24114@agk.fab.redhat.com>
	<20070711143423.36722a41.akpm@linux-foundation.org>
	<m1bqehfyp0.fsf@ebiederm.dsl.xmission.com>
Reply-To: device-mapper development <dm-devel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, dm-devel@redhat.com,
	Alasdair G Kergon <agk@redhat.com>, linux-kernel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <dm-devel-bounces@redhat.com>
Content-Disposition: inline
In-Reply-To: <m1bqehfyp0.fsf@ebiederm.dsl.xmission.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/dm-devel>
List-Post: <mailto:dm-devel@redhat.com>
List-Help: <mailto:dm-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=subscribe>
Sender: dm-devel-bounces@redhat.com
Errors-To: dm-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

Eric W. Biederman <ebiederm@xmission.com> wrote:
> I may be a little off but looking at the events types defined.
> device down, device up.  Defining a completely new interface for this
> looks absolutely absurd.
> 
> 
> This is device hotplug isn't it?   As such we should be using the
> hotplug infrastructure and not reinventing the wheel here.
> 

I assume device hotplug means kobject_uevent and KOBJ_* events. The
original intent was to have a little more structure in the data format the
env strings. I also wanted to reduce the number of allocations that where
happening with GFP_KERNEL to send an event. 

Currently the patch is only supporting a couple of events with the intent of
adding more over time. I see that I could map most events to KOBJ_CHANGE,
previously it did not seem like the correct fit.  

> If it isn't hotplug it looks like something that inotify should
> handle.
> 
> If that isn't the case I am fairly certain that md already has a
> mechanism to handle this, and those two should stay in sync
> if at all possible on this kind of thing.
> 

Device mapper does have a "event happened" interface today, but post the
event the user must determine the context of the event (dm also sends a
kobject_uevent KOBJ_CHANGE only for a resume event). This patch was only
effecting dm, but I know the md has similar infrastructure. This patch
was passing out the event context through netlink that already existed but
was lost through the current generic event interface.

The existing event interfaces was left in place to not effect existing users
allowing migration over to a netlink interface over time.

> So this appears to be a gratuitous user interface addition.
> Why do we need a new user interface for this?

While I understand Evgeniy and Davids comment about utilizing the
genetlink interface, I guess I am not seeing that utilizing a netlink
channel for a subsystem as a gratuitous user interface addition vs.
running everything through kobject_uevent.

Thanks,

-andmike
--
Michael Anderson
andmike@us.ibm.com
