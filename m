From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Sun, 25 Sep 2016 20:59:32 +0300
Message-ID: <20160925205932.57b21e93@halley>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
        <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
        <4387324a-de66-aa1b-86f0-1a9a2f8294f5@mojatatu.com>
        <20160923081106.73fb48df@halley>
        <CAM_iQpU+7NDoGGPkkDHA=v5XW5z98GHQhstFg5H=WCyiBzA-eA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34076 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965935AbcIYR7h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 13:59:37 -0400
Received: by mail-wm0-f68.google.com with SMTP id l132so10751542wmf.1
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 10:59:36 -0700 (PDT)
In-Reply-To: <CAM_iQpU+7NDoGGPkkDHA=v5XW5z98GHQhstFg5H=WCyiBzA-eA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, 24 Sep 2016 17:07:12 -0700 Cong Wang <xiyou.wangcong@gmail.com> wrote:
> One problem to use your code for us is that, the RX side of veth
> is inside containers, not visible to outside, perhaps we need some
> more parameter to tell the netns before the device name/index?
> Thoughts?

Well, this is way trickier...

tc_mirred doesn't cope with netns movement of the target device.
See 'mirred_device_event': upon NETDEV_UNREGISTER the 'tcfm_dev' gets
nullified.

(dev_change_net_namespace sequence includes NETDEV_UNREGISTER,
 dev_net_set, NETDEV_REGISTER).

As upposed to veth, which keeps the peer netdev pointer (since veth peers
lifetime is coupled), here in act_mirred we can't easily distinguish a
"real" NETDEV_UNREGISTER vs a namespace change...
