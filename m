From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: loosing netdevices with namespaces and unshare?
Date: Thu, 01 Jun 2017 01:32:49 -0500
Message-ID: <87a85si5f2.fsf@xmission.com>
References: <20170530220741.ldmhwj3bsvdoaofc@nataraja>
        <CAM_iQpW2ARBTmGK8JhVXSFCaB1F-WPDKeDZwEbxMLf_Xi7aXQw@mail.gmail.com>
        <20170531122752.siaou43verg4epep@nataraja>
        <CAM_iQpU517NR1xsrDrAohnESdS33WoToHsdGD0yOWSiGU9Yiqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Harald Welte <laforge@gnumonks.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53935 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750848AbdFAGjg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 02:39:36 -0400
In-Reply-To: <CAM_iQpU517NR1xsrDrAohnESdS33WoToHsdGD0yOWSiGU9Yiqg@mail.gmail.com>
        (Cong Wang's message of "Wed, 31 May 2017 10:44:53 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> writes:
> Network namespace does not special-case the physical devices,
> it treats them all equally as abstract net devices.

Absolutely not true.

The relevant code is in net/core/dev.c:default_device_exit

If a network device does not implement rntl_link_ops it is returned to
the initial network namespace.   Anything else will loose physical
devices.

Only for pure software based devices do we delete them.  Perhaps your
sub interface implements rtnl_link_ops?  Either that or something is
still holding a reference to your network namespace, which would prevent
the network device from being returned.

Eric
