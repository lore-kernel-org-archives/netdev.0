From: Kay Sievers <kay-tD+1rO4QERM@public.gmane.org>
Subject: Re: [PATCH v4 0/3] Send audit/procinfo/cgroup data in socket-level
 control message
Date: Thu, 23 Jan 2014 20:31:24 +0100
Message-ID: <CAPXgP11hxVLd7=OJ0-uapLUnQ4P+gsY8dcmfSi2FrenCEg7AFw@mail.gmail.com>
References: <1377614400-27122-1-git-send-email-jkaluza@redhat.com>
 <1389600109-30739-1-git-send-email-jkaluza@redhat.com> <20140115.121730.1984913330507219167.davem@davemloft.net>
 <1389828103.681.34.camel@flatline.rdu.redhat.com> <20140115232345.GA22237@mtj.dyndns.org>
 <52D7A68F.5030700@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org
To: =?UTF-8?Q?Jan_Kalu=C5=BEa?= <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52D7A68F.5030700-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 16, 2014 at 10:29 AM, Jan Kalu=C5=BEa <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> =
wrote:
> On 01/16/2014 12:23 AM, Tejun Heo wrote:
>> On Wed, Jan 15, 2014 at 06:21:43PM -0500, Eric Paris wrote:
>>>
>>> Reliably being able to audit what process requested an action is
>>> extremely useful.  And I like the audit patch, as it is a couple of=
 ints
>>> we are storing.
>>>
>>> procinfo and cgroup can both be up to 4k of data.
>>>
>>> Is there an alternative he should consider?  Some way to grab a
>>> reference on task_struct and just attach that to the message?
>>
>> Or maybe it can be made separately optional instead of tagging along
>> on an existing option so that it doesn't tax use cases which don't
>> care about the new stuff?
>
> Right, I could add new option next to SOCK_PASSCRED which could be us=
ed to
> send newly added stuff. Would this be acceptable?
>
> I would still vote for SCM_AUDIT to be part of SOCK_PASSCRED and move
> SCM_CGROUP and SCM_PROCINFO into new option.

Maybe we could just add a new SOCK_PASS_TASKINFO bit to set in
socket->flags. Set that bit with a new SO_PASS_TASKINFO sockoption.

The SOCK_PASS_TASKINFO can carry all sorts of "struct task" related
stuff, also include the audit data. It is all fully conditional, so
users which do not explicitly subscribe to TASKINFO will never see the
data or needlessly pay for the overhead.

A TASKINFO sounds generic enough to be possibly extended with new data
in the future, without wasting extra bits in the socket flags.

Users which subscribe with SO_PASS_TASKINFO expect some overhead
anyway. In the end it's still a lot cheaper than parsing /proc for the
data; which is also racy and does therefore not work for any
short-living program.

Thanks,
Kay
