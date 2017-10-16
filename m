From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: act_skbedit unable to check queue_mapping at init time
Date: Mon, 16 Oct 2017 10:36:46 -0700
Message-ID: <CAM_iQpUgp6tuKfZX3KecBtLBc-RSyQ0F-1g-ovn8GjzEyEJkcA@mail.gmail.com>
References: <c48c8af5-d4c6-d2f7-cc0f-6cb50f2a865e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Alexander Duyck <alexander.h.duyck@intel.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:47886 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752902AbdJPRhH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 13:37:07 -0400
Received: by mail-pg0-f43.google.com with SMTP id r25so7371045pgn.4
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 10:37:07 -0700 (PDT)
In-Reply-To: <c48c8af5-d4c6-d2f7-cc0f-6cb50f2a865e@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Florian

On Wed, Oct 11, 2017 at 12:02 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Hi all,
>
> It is perfectly possible for the following to happen:
>
> # ls /sys/class/net/gphy/queues
> rx-0  tx-0  tx-1  tx-2  tx-3
> # tc qdisc add dev gphy root handle 1: multiq
> # tc filter add dev gphy parent 1: protocol ip prio 1 u32
>  match ip dst 192.168.1.1 action skbedit queue_mapping 5
>
> that specifies a queue_mapping value that exceeds what the underlying
> device supports. There is a check for dev->real_num_tx_queue >
> d->queue_mapping in tcf_skbedit() which makes sure we won't overflow the
> queue space, but this will essentially render the action inactive.
>
> I can't find a way to get a reference on a network device from a
> tc_action_ops->init function in order to validate that the queue_mapping
> is valid at ->init() time and return an appropriate error if we are
> exceeding what the device does. This is an action chained to a match and
> a filter, so somehow one would think it would be possible to obtain a
> reference on the network device the filter was installed on...
>
> Any clues how we could fix that?

The problems is actions could be standalone and shared by multiple
filters, it is impossible to check it for this case. However, it is possible
to check it for non-standalone case, the parameter 'bind' indicates it.
You still need to find a way to get either the tp pointer or dev pointer.

Thanks.
