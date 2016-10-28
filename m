From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [Intel-wired-lan] [net-next PATCH 3/3] net: Add support for XPS
 with QoS via traffic classes
Date: Fri, 28 Oct 2016 08:49:40 -0700
Message-ID: <58137394.4050803@gmail.com>
References: <20161027153539.13989.14349.stgit@ahduyck-blue-test.jf.intel.com>
 <20161027154014.13989.33421.stgit@ahduyck-blue-test.jf.intel.com>
 <CALx6S36F=6R12O6Xb-WfhruOQN7S6QjOite7PVW2JqNK5BtWYg@mail.gmail.com>
 <CAKgT0UcZY4eKP0ezsijiJquqGKEwap8kA3Kqmg0BRYL8JF_90g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        "David S. Miller" <davem@davemloft.net>
To: Alexander Duyck <alexander.duyck@gmail.com>,
        Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36063 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754677AbcJ1Ptw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 11:49:52 -0400
Received: by mail-pf0-f193.google.com with SMTP id n85so1601074pfi.3
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 08:49:52 -0700 (PDT)
In-Reply-To: <CAKgT0UcZY4eKP0ezsijiJquqGKEwap8kA3Kqmg0BRYL8JF_90g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-28 07:58 AM, Alexander Duyck wrote:
> On Thu, Oct 27, 2016 at 7:38 PM, Tom Herbert <tom@herbertland.com> wrote:
>> On Thu, Oct 27, 2016 at 8:40 AM, Alexander Duyck
>> <alexander.h.duyck@intel.com> wrote:
>>> This patch adds support for setting and using XPS when QoS via traffic
>>> classes is enabled.  With this change we will factor in the priority and
>>> traffic class mapping of the packet and use that information to correctly
>>> select the queue.
>>>
>>> This allows us to define a set of queues for a given traffic class via
>>> mqprio and then configure the XPS mapping for those queues so that the
>>> traffic flows can avoid head-of-line blocking between the individual CPUs
>>> if so desired.
>>>
>> Does this change the sys API for XPS? Is it up the user to know which
>> are priority queues in sys?
> 
> The idea was to keep the change transparent.  So for now the only
> change in relation to XPS from the XPS point of view is that the map
> for a given queue is invalidated when either the dev->num_tcs changes
> or if the queue is moved into a dev->tx_to_txq mapping.  Otherwise the
> interface should behave exactly the same as before.
> 
> One thing I could look at doing is adding a read-only sysfs value that
> the user could use to identify which traffic class a given queue
> belongs to.  Then at least that way they would be able to dump both
> the XPS map and the tc to determine how the traffic will flow through
> the device.
> 

I could see some value in a sysfs read-only tc-queue mapping might be
especially for devices that are negotiating these things using firmware.

.John
