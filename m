From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Mon, 26 Sep 2016 18:26:54 +0300
Message-ID: <20160926182654.292838e6@halley>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
        <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
        <4387324a-de66-aa1b-86f0-1a9a2f8294f5@mojatatu.com>
        <20160923081106.73fb48df@halley>
        <0037729a-a3fc-c1c9-a620-905c73e0b9d4@mojatatu.com>
        <20160923184030.75124289@halley>
        <6d2bd45a-a8a0-846d-5934-5e246522cab8@mojatatu.com>
        <20160925203309.633cf3d5@halley>
        <20160925183136.GA3307@breakpoint.cc>
        <54535aa0-cafd-86ec-1f6c-64c974a5eed6@mojatatu.com>
        <20160926013504.GA1959@breakpoint.cc>
        <54aa5404-f4c8-03e1-0b62-8c070bd6d65b@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35258 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161190AbcIZP1E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 11:27:04 -0400
Received: by mail-wm0-f65.google.com with SMTP id 133so14655841wmq.2
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 08:27:04 -0700 (PDT)
In-Reply-To: <54aa5404-f4c8-03e1-0b62-8c070bd6d65b@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, 26 Sep 2016 16:43:16 +0200 Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> On 26.09.2016 03:35, Florian Westphal wrote:
> > 
> > Yes, but I think we get same issue when we deal with stacked
> > interfaces, and redirect is to e.g. vlan on top of physical device.  
> 
> We do have the adjacent upper lists in all netdevices, calculating if a
> mirred actions would insert the skb on a stacked device above us should
> be as easy as querying netdev_has_upper_dev and should be possible to
> check that during config time.

This does not seem the right direction:

- We should NOT ban egress redirect to an "upper device", this limits
  flexibility available today:
  One may validly redirect to an "upper device" according to a very
  specific criteria such that the skb will NOT be caught again by the
  filter when re-iterated down the stack.

- And even if we did, at "config time" as you say, one can always stack
  the target device ontop the filtered device at a LATER time.
  And obviously, testing "is upper" while executing action is a bad idea.

- Moreover, as Daniel noted, this is just a band-aid which limitely
  addresses only few of the already existing troubles with stacked
  virtual netdevices (with or without act_mirred).

Frankly, I think the loop-detection suggestions overload act_mirred
with AI that might imply limitations not well assessed (even on existing
usecases).

If needed, I'd go with the "recursion detection" suggested by Daniel,
which is simple and aids with the issues of "egress" redirect that
already exist today.

Moreover, as the patch series is all about "ingress redirect" support,
the "recursion detection" deserves a series of its own, we shouldn't
bundle these two distinct features.

Regards,
Shmulik
