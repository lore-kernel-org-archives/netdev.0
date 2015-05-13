From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] net/bridge: Enable bridge also when switchdev
 can't be built
Date: Wed, 13 May 2015 08:54:25 -0700
Message-ID: <CAE4R7bCY8UocUR7yqn2LTFe6Hu6BxDRuu5PAbeZ+q-JxoP6sxQ@mail.gmail.com>
References: <1431511723-26323-1-git-send-email-ogerlitz@mellanox.com>
	<CAE4R7bCO3Zs=NzZDz9WTKRJznU7BMOkNNZFewNttUXqYsYUq0A@mail.gmail.com>
	<20150513154743.GA2773@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:36438 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965261AbbEMPy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 11:54:28 -0400
Received: by qku63 with SMTP id 63so31057741qku.3
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 08:54:26 -0700 (PDT)
In-Reply-To: <20150513154743.GA2773@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 13, 2015 at 8:47 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Wed, May 13, 2015 at 05:44:11PM CEST, sfeldma@gmail.com wrote:
>>On Wed, May 13, 2015 at 3:08 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>>> Currently switchdev doesn't build on older gcc version such as 4.4.6
>>>
>>> The reason for the compile error is such that it causes a failure
>>> to build the bridge too, even when switchdev isn't configured (the
>>> stub isn't enough), fix it.
>>>
>>> CC [M]  net/bridge/br_stp.o
>>> net/bridge/br_stp.c: In function 'br_set_state':
>>> net/bridge/br_stp.c:44: error: unknown field 'stp_state' specified in initializer
>>>
>>> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>>> ---
>>>  net/bridge/br_stp.c |    4 +++-
>>>  1 files changed, 3 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
>>> index b9300da..752783a 100644
>>> --- a/net/bridge/br_stp.c
>>> +++ b/net/bridge/br_stp.c
>>> @@ -39,17 +39,19 @@ void br_log_state(const struct net_bridge_port *p)
>>>
>>>  void br_set_state(struct net_bridge_port *p, unsigned int state)
>>>  {
>>> +#ifdef CONFIG_NET_SWITCHDEV
>>>         struct switchdev_attr attr = {
>>>                 .id = SWITCHDEV_ATTR_PORT_STP_STATE,
>>>                 .stp_state = state,
>>>         };
>>>         int err;
>>>
>>> -       p->state = state;
>>>         err = switchdev_port_attr_set(p->dev, &attr);
>>>         if (err && err != -EOPNOTSUPP)
>>>                 br_warn(p->br, "error setting offload STP state on port %u(%s)\n",
>>>                                 (unsigned int) p->port_no, p->dev->name);
>>> +#endif
>>> +       p->state = state;
>>>  }
>>
>>Isn't this the same issue with anonymous unions and older gcc?
>
> I believe it is

Ok, I'll have a patch shortly to add ".u"...
