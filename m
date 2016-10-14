From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next RFC 0/6] Add support for offloading packet-sampling
Date: Thu, 13 Oct 2016 22:02:04 -0700
Message-ID: <CAJieiUjdfWSEgoPYdQ+a6q9XYWEWCg-F30vEKb5FxuwebP_E2Q@mail.gmail.com>
References: <1476276069-5315-1-git-send-email-jiri@resnulli.us>
 <57FF37F5.4070100@cumulusnetworks.com> <20161013084857.GC1816@nanopsycho.orion>
 <64872c5b-8cbc-edd8-00aa-afc87a7cfa4a@mojatatu.com> <20161013121022.GD1816@nanopsycho.orion>
 <2cc65dfa-de32-2e31-5f03-80e8f0d2586f@mojatatu.com> <20161013124526.GF1816@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Yotam Gigi <yotamg@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Elad Raz <eladr@mellanox.com>,
        Nogah Frankel <nogahf@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, geert+renesas@glider.be,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Guenter Roeck <linux@roeck-us.net>,
        Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:36234 "EHLO
        mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754409AbcJNFc3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 01:32:29 -0400
Received: by mail-vk0-f50.google.com with SMTP id 2so102987526vkb.3
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 22:32:29 -0700 (PDT)
In-Reply-To: <20161013124526.GF1816@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 13, 2016 at 5:45 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Oct 13, 2016 at 02:30:19PM CEST, jhs@mojatatu.com wrote:
>>On 16-10-13 08:10 AM, Jiri Pirko wrote:
>>> Thu, Oct 13, 2016 at 01:49:07PM CEST, jhs@mojatatu.com wrote:
>>> > On 16-10-13 04:48 AM, Jiri Pirko wrote:
>>
>>[..]
>>> > Roopa, did you mean eth1 as the new device or did you mean just in
>>> > general config requiring a device to be specified or did you mean a new
>>> > cpu netdev being needed? I couldnt tell from the patch.
>>>
>>> You just have to have some netdev to use to funnel the IFE headered
>>> sample skbs to userspace. A dummy or a tap.
>>>
>>
>>I see.
>>So with nflog you get basically a backend using a netlink socket
>>but in your case you will redirect to tuntap for the case of local
>>sflow but some other device for remote? I am assuming using dummy
>>would require a packet socket as means of retrieving the data.
>
> Correct. The idea is that the userspace app would create a tap device,
> setup the sampling packets to be sent there and recieve them
> over chardev. Or the remote delivery could be use to push the sampling
> packet to a remote host.
>
>
>>If you take the structuring of the metadata that nflog uses it should
>>be easy to transpose.
>
> Yes, we do it with IFE, this patchset implements that.
>
>
>>To Roopa's point, however: Would it not make sense to support nflog
>>(in addition?).
>>

[sorry responding to all conversations so far here]

using ife for delivery of sampled packets to remote is a good option
to have if you have users.
so far I have seen agents collecting samples locally and have their
own protocol to ship them
to a collector (example sflow). Just bringing that up so that we don't
optimize for the less common case
and make the common case difficult to use :).

In my conversations with the sflow people (founders) and others,
netlink as a mechanism for sampled packet
delivery (similar to ulog/nflog) has proven useful and they see it as
a great API to standardize on going forward (Given they are
already using netlink for collecting other samples like stats etc).
something to thing about.
The people I know collecting samples are happy with having netfilter.
agreed that tc already has an existing hw
offload mechanism. and I was not suggesting giving up on tc either.

and also to jiri, agree, I don't think logging from the driver is a
good option. I was merely suggesting
having a similar option without the need for a new collector device.

The three steps in the patch series to collect samples + a device
seems a bit heavy weight.
but, if you think you have users for it, sure. having multiple api's
is also an option.
But api's come with a cost of maintaining them for ever.
