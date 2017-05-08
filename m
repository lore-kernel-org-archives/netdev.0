From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC net-next v2 4/4] net/sched: cls_flower: allow control
 of tree traversal on packet parse errors
Date: Mon, 8 May 2017 13:54:37 +0200
Message-ID: <20170508115436.GA13253@vergenet.net>
References: <1493988426-22854-1-git-send-email-simon.horman@netronome.com>
 <1493988426-22854-5-git-send-email-simon.horman@netronome.com>
 <6c618cf6-99ec-d2e1-f1ed-dfae0bf54de7@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Benjamin LaHaise <benjamin.lahaise@netronome.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36720 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753228AbdEHLyl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 07:54:41 -0400
Received: by mail-wm0-f54.google.com with SMTP id u65so81754068wmu.1
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 04:54:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <6c618cf6-99ec-d2e1-f1ed-dfae0bf54de7@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 08, 2017 at 07:32:02AM -0400, Jamal Hadi Salim wrote:
> On 17-05-05 08:47 AM, Simon Horman wrote:
> >Allow control how the tree of qdisc, classes and filters is further
> >traversed if an error is encountered when parsing the packet in order to
> >match the cls_flower filters at a particular prio.
> >
> >By default continue to the next filter, the behaviour without this patch.
> >
> >A use-case for this is to allow configuration of dropping of packets with
> >truncated headers.
> >
> >For example, the following drops IPv4 packets that cannot be parsed by the
> >flow dissector up to the end of the UDP ports - e.g. because they are
> >truncated, and instantiates a continue action based on the port for packets
> >that can be parsed.
> >
> > # tc qdisc del dev eth0 ingress; tc qdisc add dev eth0 ingress
> > # tc filter add dev eth0 protocol ip parent ffff: flower \
> >       indev eth0 ip_proto udp dst_port 80 truncated drop action continue
> >
> >Signed-off-by: Simon Horman <simon.horman@netronome.com>
> >Reviewed-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>
> 
> I agree with Cong on this. The default should be "didnt match" (which
> is accomplished by returning -1).

The default value for err_action is TC_ACT_UNSPEC (-1).
So I think we are in agreement there.

> The user could enter an explicit
> rule to override this behavior. i.e something like:
> 
> tc filter add dev eth0 protocol ip parent ffff: flower \
>         indev eth0 ip_proto udp dst_port 80 truncated action continue

This part I am struggling with but I will see what I can do
by making truncated part of the flow key .
