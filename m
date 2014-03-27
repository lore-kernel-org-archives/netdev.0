From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next RFC v2 0/6] introduce infrastructure for support
 of switch chip datapath
Date: Thu, 27 Mar 2014 09:27:58 -0700
Message-ID: <CAGVrzcYE9uuD0Gxd5-OND4p5ieikYFchhpBm=ZiK5GaMqiQVyA@mail.gmail.com>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
 <53334A3F.6020105@mojatatu.com> <20140327072107.GC2845@minipsycho.orion>
 <5333FD12.9060404@mojatatu.com> <20140327110223.GA1615@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	dev <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:50381 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754902AbaC0Q2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 12:28:38 -0400
Received: by mail-pd0-f170.google.com with SMTP id v10so3607612pde.1
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 09:28:38 -0700 (PDT)
In-Reply-To: <20140327110223.GA1615@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-03-27 4:02 GMT-07:00 Thomas Graf <tgraf@suug.ch>:
> On 03/27/14 at 06:27am, Jamal Hadi Salim wrote:
>> On 03/27/14 03:21, Jiri Pirko wrote:
>> >Wed, Mar 26, 2014 at 10:44:31PM CET, jhs@mojatatu.com wrote:
>>
>> >Well, I think there are 2 main models to be considered:
>> >1. OSV-like model, where everything is flows and that is the OneWay(tm)
>> >    mode you mentioned :)
>> >2. clasic switch setting-like model where you manually set up vlans,
>> >    lag, whatever.
>> >
>> >The phase one for me is 1. and that is what I'm trying to resolve with
>> >this patchset.
>> >
>> > From what I understand from the discussion, 2. is likely the model you
>> >have in mind.
>> >
>>
>> In my opinion there is no difference when setting the ACL table(s).
>> We are going to need your .ndo for more than flows. Something
>> in the stack is going to have to talk to those .ndo interfaces
>> (I keep bringing up the concept of routing code for example).
>> What i meant by no OneWay is i think it will depend on the
>> chip - some will require more work than other. I do believe it
>> is a longer discussion needed than the port resolving.
>
> There is definitely need beyond an ndo that is capable of
> adding flows. You mention routes. Another example would be
> devices capable of offloading iptables & nft rules.

Those devices usually require (at least for Broadcom) an entity
identifying the flows and uploading flows offloading rules to the
hardware. Although I do not think it hurts to keep those in mind to
come up with the right design, my feeling is that they will require
more intrusive modifications at the socket, route and forwarding path
level if we want the Linux kernel to offer a consistent API across
different hardware variations.

It is not clear to me at this point whether we want those special
offloading devices to appear as separate net_device with specific
flags to advertise their offloading features (NAT, IP routing...) or
something else?

>
> But wouldn't you want to introduce an additional ndo to
> cover these?

I would start with making sure everyone is on the same page regarding
switches before we start building the conversation on NAT/IP-routing
offloading, but it is good that you mention it.

>
> What speaks against going with what Jiri proposes and adjust
> & extend as needed as we go along?


-- 
Florian
