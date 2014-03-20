From: Jesse Gross <jesse@nicira.com>
Subject: Re: openvswitch question
Date: Thu, 20 Mar 2014 09:29:25 -0700
Message-ID: <CAEP_g=_EpSn6hufAuX6ZD2fRykCbS+pmRhLZAupaebpfnk0Q3A@mail.gmail.com>
References: <CAGZFCEHSVpH8XN4n3A3xhVtYNqp4kn3PM7aXWRCxKFSkQVfABQ@mail.gmail.com>
 <CAEP_g=8=BxsXe7PNPAvyEVCDFLCRrskEPVf1ts6Aoo4-eRtQug@mail.gmail.com> <CACP96tRY6frA9gfxZCMucKjd3zdCFMUgqKQtTB8umPmqYeRkYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ratheesh kannoth <ratheesh.ksz@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: sowmini varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog036.obsmtp.com ([74.125.150.110]:43323 "HELO
	na6sys009bog036.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757244AbaCTQgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 12:36:42 -0400
Received: by mail-ig0-f170.google.com with SMTP id uq10so17643378igb.1
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 09:36:38 -0700 (PDT)
In-Reply-To: <CACP96tRY6frA9gfxZCMucKjd3zdCFMUgqKQtTB8umPmqYeRkYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 20, 2014 at 3:26 AM, sowmini varadhan <sowmini05@gmail.com> wrote:
> On Wed, Mar 19, 2014 at 9:36 PM, Jesse Gross <jesse@nicira.com> wrote:
> evel/19402
>>
>> From the perspective of the network stack, there is no difference
>> between Open vSwitch internal devices and real NICs so the entry
>> points into the stack are the same.
>
> However, the internal vswitch ports like patch-tun and patch-int
> are not standard net_devices, so they cannot, e.g.,  be tcpdump'ed,
> correct?

Patch ports exist only in userspace in order to avoid multiple
redundant lookups, so, yes, they cannot be tcpdumped.

> FWIW, I've already raised an issue with tcpdump/ovswitch mirroring
>  in the openstack-dev list, but repeat
> it here, in the hope that someone can shed some light on what
> I need to make this work. I'm using a ubuntu 13.10 qemu-kvm
> where I'm running openvswitch 1.10.2.
>
> " I'm following the instructions at
>   http://docs.openstack.org/trunk/openstack-ops/content/network_troubleshooting.html
>
>   to set up patch-tun mirrors, but running tcpdump on the "snooper0"
>   produces inconsistent results- sometimes, I'm able to get a copy
>   of the packet (e.g., the syn packet for ssh below) but not others
>   (the tcpdump session did not show any more packets, for example).
>
>   Why is this?

Mirroring should work. You would have to look at the packets entering
the switch and then trying to look at the flows (using ovs-dpctl
dump-flows and ovs-appctl ofproto/trace) to figure out what is
different.
