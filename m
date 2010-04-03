From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH 0/6] tagged sysfs support
Date: Sat, 3 Apr 2010 10:35:57 +0200
Message-ID: <h2gac3eb2511004030135q2a2f5002z912974c1d2ab8853@mail.gmail.com>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org> <ac3eb2511003301153i43a60720hb015071e2c992199@mail.gmail.com>
	<m14ojxh0mz.fsf@fess.ebiederm.org> <s2hac3eb2511003302251rcbae8767ne21e9daf1546c849@mail.gmail.com>
	<1270256303.12516.234.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kroah-Hartman <gregkh@suse.de>, Greg KH <greg@kroah.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1270256303.12516.234.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 3, 2010 at 02:58, Ben Hutchings <ben@decadent.org.uk> wrote=
:
> On Wed, 2010-03-31 at 07:51 +0200, Kay Sievers wrote:
>> Yeah, /sys/bus/, which is the only sane layout of the needlessly
>> different 3 versions of the same thing (bus, class, block).
> [...]
>
> block vs class/block is arguable,

That's already done long ago.

> but as for abstracting the difference
> between bus and class... why?

There is absolutely no need to needlessly export two versions of the
same thing. These directories serve no other purpose than to collect
all devices of the same subsystem. There is no useful information that
belongs to the type class or bus, they are both the same. Like
"inputX" is implemented as a class, but is much more like a bus. And
"usb" are devices, which are more a class of devices, and the
interfaces and contollers belong to a bus.

There is really no point to make userspace needlessly complicated to
distinguish the both.

We also have already a buch of subsystems which moved from class to
bus because they needed to express hierarchy between the same devices.
So the goal is to have only one type of subsystem to solve these
problems.

> Each bus defines a device interface covering enumeration,
> identification, power management and various aspects of their connect=
ion
> to the host. =C2=A0This interface is implemented by the bus driver.

Sure, but that does not mean that class is a useful layout, or that
class devices can not do the same.

> Each class defines a device interface covering functionality provided=
 to
> user-space or higher level kernel components (block interface to
> filesystems, net driver interface to the networking core, etc). =C2=A0=
This
> interface is implemented by multiple device-specific drivers.

That's absolutely wrong. Classes are just too simple uses of the same
thing. We have many class devices which are not "interfaces", and we
have bus devices which are interfaces.

> So while buses and classes both define device interfaces, they are
> fundamentally different types of interface.

No, they are not. They are just "devices". There is no useful
difference these two different types expose. And the class layout is
fundamentally broken, and not extendable. Peole mix lists of devices
with custom subsystem-wide attributes, which we need to stop from
doing this. The bus layout can carry custom directories, which is why
we want that by default for all "classifications".

> And there are 'subsystems'
> that don't have devices at all (time, RCU, perf, ...). =C2=A0If you'r=
e going
> to expose the set of subsystems, don't they belong in there?
> But then,

We are talking about the current users in /sys, and the difference in
the sysfs export between /sys/bus and /sys/class.

> what would you put in their directories?

We are not talking about anything not in /sys currently.

Kay
