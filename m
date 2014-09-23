From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Mon, 22 Sep 2014 18:36:44 -0700
Message-ID: <5420CEAC.2070104@gmail.com>
References: <20140919154946.GH1980@nanopsycho.orion> <541C6E6D.9000109@mojatatu.com> <541CAA3C.5080105@intel.com> <20140920081426.GE1821@nanopsycho.orion> <20140920105354.GA29419@casper.infradead.org> <CAADnVQK0wT2Fjqdg+C=ruSt8jF6sKeMo7cFj7K1fsu7-1u5g=g@mail.gmail.com> <20140922081341.GA20905@casper.infradead.org> <CA+mtBx-ZvkZ2ALGLsLEN7Cgn9gN_rY36ZhuqYC3mZ9WVxjFDaQ@mail.gmail.com> <20140922221727.GA4708@casper.infradead.org> <CA+mtBx9ZVQ5r5Hzy9-uEnk+iu+HKkOP4+VANC06Xf8VvTxktwQ@mail.gmail.com> <20140922225305.GB4708@casper.infradead.org> <CA+mtBx94TrLzQrZDo58d9ktma3ZioOpO=2FAODMRoiyiuYkQ9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Vladislav Yasevich <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prab
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:64233 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbaIWBhc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 21:37:32 -0400
Received: by mail-oi0-f43.google.com with SMTP id v63so4044294oia.16
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 18:37:31 -0700 (PDT)
In-Reply-To: <CA+mtBx94TrLzQrZDo58d9ktma3ZioOpO=2FAODMRoiyiuYkQ9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/2014 04:07 PM, Tom Herbert wrote:
> On Mon, Sep 22, 2014 at 3:53 PM, Thomas Graf <tgraf@suug.ch> wrote:
>> On 09/22/14 at 03:40pm, Tom Herbert wrote:
>>> On Mon, Sep 22, 2014 at 3:17 PM, Thomas Graf <tgraf@suug.ch> wrote:
>>>> What makes stateful offload interesting to me is that the final
>>>> desintation of a packet is known at RX and can be redirected to a
>>>> queue or VF. This allows to build packet batches on shared pages
>>>> while preserving the securiy model.
>>>>
>>> How is this different from what rx-filtering already does?
>>
>> Without stateful offload I can't know where the packet is destined
>> to until after I've allocated an skb and parsed the packet in
>> software. I might be missing what you refer to here specifically.
>
> n-tuple filtering in as exposed by ethtool.

n-tuple has some deficiencies,

	- its not possible to get the capabilities to learn what
	  fields are supported by the device, what actions, etc.

	- its ioctl based so we have to poll the device

	- only supports a single table, where we have devices with
	  multiple tables

	- sort of the same as above but it doesn't allow creating new
	  tables or destroying old tables.

I probably missed a few others but those are the main ones that I
would like to address. Granted other than the ioctl line the rest could
be solved by extending the existing interface. However I would just
assume port it to ndo_ops and netlink then extend the existing ioctl
seeing it needs a reasonable overall to support the above anyways.

We could port the ethtool ops over to the new interface to
simplify drivers.

.John

-- 
John Fastabend         Intel Corporation
