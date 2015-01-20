From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next] bridge: ability to disable forwarding on
 a port
Date: Mon, 19 Jan 2015 22:20:55 -0800
Message-ID: <54BDF3C7.5010806@cumulusnetworks.com>
References: <1421479975-62049-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bBeNojtj3Zyd6+zSJFGRjG4vejBObnS1XUFAfJDZJZYow@mail.gmail.com> <54BB7874.90201@cumulusnetworks.com> <54BC1DC5.1000401@cumulusnetworks.com> <CAE4R7bC=j-mT65TzFOhJL-Hd0GeHg3-k+=+VFHaj-m+h5PjMuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"Arad, Ronen" <ronen.arad@intel.com>, Thomas Graf <tgraf@suug.ch>,
	john fastabend <john.fastabend@gmail.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	Wilson Kok <wkok@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:39837 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756AbbATGU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 01:20:58 -0500
Received: by mail-pd0-f179.google.com with SMTP id v10so22785030pde.10
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 22:20:57 -0800 (PST)
In-Reply-To: <CAE4R7bC=j-mT65TzFOhJL-Hd0GeHg3-k+=+VFHaj-m+h5PjMuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/18/15, 11:37 PM, Scott Feldman wrote:

<snip..>
>
> Not sure. I don't know the use case, but I think I might have heard that
> there could be a case
>   where a switch port could be bridged with a vm's port running on the
> switch. (?)
>>
>> Ignoring the above usecase for a bit. And thinking through this again, It
>> appears that this check should
>> be only on the ingress port, no ?
>>
>> If the ingress bridge port is an offloaded port, don't flood or forward
>> because hardware has already done it.
>> And this is best done with the offload feature flag on the bridge port.
> That's assuming hardware did the flood.  Maybe your other option to
> mark the skb if already flooded by hw is best.  That's enough info for
> the bridge driver to make a decision to flood or not to the other
> ports, and it's an implementation decision for the driver/device to do
> the flood offload, if desired, and mark the skb if it did.

Still thinking we can just use the offload feature flag here. How about  
avoid forwarding only if both src and dst ports have
forwarding offloaded/accelerated by a switch asic  ?. That should cover 
all cases.
>
> Btw, you're still saying flood or forward, but in my mind we're
> talking about flood only: flood of unknown unicast or flood of
> bcast/mcast pkts.  Forwarding would be for known-unicast pkts, which
> should even involve the bridge driver since that forwarding is
> offloaded to the device.

I was also taking into account pkts copied to the CPU due to an acl rule such as log.
These unicast pkts can come to cpu even if it is already forwarded in hw.


Thanks,
Roopa
  
