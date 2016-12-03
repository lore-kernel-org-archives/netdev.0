From: Simon Horman <simon.horman@netronome.com>
Subject: Re: Possible regression due to "net/sched: cls_flower: Add offload
 support using egress Hardware device"
Date: Sat, 3 Dec 2016 18:54:12 +0100
Message-ID: <20161203175410.GA2147@penelope.horms.nl>
References: <20161203131758.GA4695@verge.net.au>
 <CAJ3xEMiTgDq-qE_HEdGc-F7U24Be+XS6RtsG-22zUzrV1Z_neA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Roi Dayan <roid@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35903 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751056AbcLCRyP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 12:54:15 -0500
Received: by mail-wm0-f54.google.com with SMTP id g23so44754323wme.1
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 09:54:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMiTgDq-qE_HEdGc-F7U24Be+XS6RtsG-22zUzrV1Z_neA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 03, 2016 at 06:06:08PM +0200, Or Gerlitz wrote:
> On Sat, Dec 3, 2016 at 3:17 PM, Simon Horman <horms@verge.net.au> wrote:
> 
> > in net-next I am observing what appears to be an regression in net-next due to:
> > 7091d8c7055d ("net/sched: cls_flower: Add offload support using egress Hardware device")
> >
> > The problem occurs when adding a flower filter (without offload to a virtio device).
> 
> > # ethtool -d eth0
> > ethtool -i eth0
> > driver: virtio_net
> 
> > # tc qdisc add dev eth0 ingress
> > # tc filter add dev eth0 protocol ip parent ffff: flower indev eth0
> > [  104.302779] BUG: unable to handle kernel NULL pointer dereference at 00000000000000d5
> 
> Simon, I don't see an action here, is that missing in purpose? wasn't
> sure what such filter does, but ofcourse
> if it was supported by the patches it has to be so after changing
> things as well, we will check and fix.
> 

Hi Or,

sorry, I trimmed the action by mistake when trying to make a minimal test
case. Originally I noticed this bug with something like the following:

tc filter add dev eth0 protocol ip parent ffff: flower indev eth0 ip_proto udp dst_port 53 action drop

I don't think the fields flower is matching on or the action are
particularly important when trying to reproduce the problem. But I could be
wrong.
