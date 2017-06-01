From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: loosing netdevices with namespaces and unshare?
Date: Thu, 01 Jun 2017 02:48:01 -0500
Message-ID: <8760gggnda.fsf@xmission.com>
References: <20170530220741.ldmhwj3bsvdoaofc@nataraja>
        <CAM_iQpW2ARBTmGK8JhVXSFCaB1F-WPDKeDZwEbxMLf_Xi7aXQw@mail.gmail.com>
        <20170531122752.siaou43verg4epep@nataraja>
        <CAM_iQpU517NR1xsrDrAohnESdS33WoToHsdGD0yOWSiGU9Yiqg@mail.gmail.com>
        <87a85si5f2.fsf@xmission.com>
        <20170601070031.mdycexartsu33fyd@nataraja>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:43911 "EHLO
        out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751036AbdFAHyt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 03:54:49 -0400
In-Reply-To: <20170601070031.mdycexartsu33fyd@nataraja> (Harald Welte's
        message of "Thu, 1 Jun 2017 09:00:31 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Harald Welte <laforge@gnumonks.org> writes:

> Hi Eric,
>
> On Thu, Jun 01, 2017 at 01:32:49AM -0500, Eric W. Biederman wrote:
>
>> If a network device does not implement rntl_link_ops it is returned to
>> the initial network namespace.   Anything else will loose physical
>> devices.
>
> Thanks a lot for your statement.  This is a big relief, my line of
> thinking thus is confirmed:  We shall not loose physical devices.

Rereading that I should have said:
    We shall not lose physical devices.
We should let the loose to talk and say interesting things to the world.

>> Only for pure software based devices do we delete them.  Perhaps your
>> sub interface implements rtnl_link_ops?  Either that or something is
>> still holding a reference to your network namespace, which would prevent
>> the network device from being returned.
>
> My question is how to debug this further?  Monitoring
> /proc/*/ns/net* showed that the ID of the namespace is gone after
> terminating my processes in the namespace.  Short of adding printk() or
> playing with kprobes: to the related kernel code, how can I track the
> reference count or get an idea who might hold references?

You mentioned sub-interface.  I would first look to see if your
sub-interface might possibly implement rtnl_link_ops.

For testing I would toss in a full fledged physical interface and
see if that pops back.  Just to verify what you are seeing happening is
happening.

In your minimal test case of "unshare -Urn bash -c 'sleep 1; exit 0;'" I
can't imagine there is anything holding a reference.  So it may come
down to adding some printks or playing with kprobes.

All of macvlans and vlans and anything I can think of as sub-interface
all implement rtnl_link_ops and will get deleted when a network
namespace exits.  Which generally is what you want as it gives a very
nice cleanup.

Eric
