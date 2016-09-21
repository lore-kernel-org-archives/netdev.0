From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 01/15] i40e: Introduce VF port representor/control netdevs
Date: Wed, 21 Sep 2016 22:21:18 +0300
Message-ID: <CAJ3xEMj-teLmjg+Nzn0pHsnz8P=EY6uF4VzDJsxVEOTihStrLw@mail.gmail.com>
References: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1474429432-102772-2-git-send-email-jeffrey.t.kirsher@intel.com>
 <CAJ3xEMhtyrS_jKrZ8UYWDi-UjK4RuxbwUSs8H=nFqWrTgzDVdw@mail.gmail.com>
 <57E21E74.5090707@intel.com> <CAJ3xEMgMkz1FZ-QObMvc28JQT0Osrf-k7_RfanUYkYP=F8jZGQ@mail.gmail.com>
 <57E2BC74.5040905@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>,
        guru.anbalagane@oracle.com, Ilya Lesokhin <ilyal@mellanox.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Rony Efraim <ronye@mellanox.com>
To: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34159 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933604AbcIUTVU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 15:21:20 -0400
Received: by mail-oi0-f67.google.com with SMTP id a62so4570754oib.1
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 12:21:19 -0700 (PDT)
In-Reply-To: <57E2BC74.5040905@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2016 at 7:59 PM, Samudrala, Sridhar
<sridhar.samudrala@intel.com> wrote:
> On 9/21/2016 12:04 AM, Or Gerlitz wrote:


>> so what happens after this patchset is applied and before the future work is
>> submitted? RX/TX slow path through the VFPRs isn't supported and what
>> about fast path? in other words what happens when someone
>> loads the driver, sets SRIOV (--> the driver set itself to switchdev mode
>> and VFPRs are created) and then a VF sends a packet? do you still put
>> into the HW the legacy DMAC based switching rules? I am not following...

> The VF driver requests adding the dmac based filter rules via mailbox
> messages to PF and that is not changed in this patchset.
> Once we have VFPR TX/RX support, we will not allow the VF driver to add
> these rules, Instead a host based
> program will be able to add these rules to enable the fast path.

I see, this means that when this patch set is applied your driver
reports through devlink that they are in switchdev mode, but the
operational state of the VFs and VFPRs isn't such - as the VFs dictate
the steering and the VFPRs don't support slow path TX/RX --- in an
earlier comment you made on this thread you said that you will be
submitting RX/TX support in the next patchset. Maybe it would be best
if you can take the VFPRs patches out of this series and roll a follow
up series with all what's needed? unless you need more time and gonna
miss 4.9 as of that... if the patches are ready, I say lets have them
all in one series, if not, I wonder what other people think on the
matter. I am basically half+ good to have also the half baked code
base merged

Anyway, there's no point to report through ethtool something (VF vport
HW stats) you can report in the standard and convenient manner, so
this one please do address regardless of the prev comment.

Or.
