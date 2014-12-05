From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 1/3] netdev: introduce new NETIF_F_HW_SWITCH_OFFLOAD feature
 flag for switch device offloads
Date: Fri, 05 Dec 2014 11:07:16 -0800
Message-ID: <54820264.8000008@cumulusnetworks.com>
References: <1417746401-8140-2-git-send-email-roopa@cumulusnetworks.com> <20141205074127.GB1866@nanopsycho.orion> <5481BE27.6000505@cumulusnetworks.com> <CAE4R7bBzQQeQAHof=gObugmOGdGE-e5GRh=6V2+KJbctity9pw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
	Benjamin LaHaise <bcrl@kvack.org>, Thomas Graf <tgraf@suug.ch>,
	john fastabend <john.fastabend@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	John Linville <linville@tuxdriver.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"buytenh@wantstofly.org" <buytenh@wantstofly.org>,
	Aviad Raveh <aviadr@mellanox.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, shm@cumulusnetworks.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:35382 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbaLETHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 14:07:31 -0500
In-Reply-To: <CAE4R7bBzQQeQAHof=gObugmOGdGE-e5GRh=6V2+KJbctity9pw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/5/14, 10:53 AM, Scott Feldman wrote:
> On Fri, Dec 5, 2014 at 6:16 AM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>> On 12/4/14, 11:41 PM, Jiri Pirko wrote:
>>> Fri, Dec 05, 2014 at 03:26:39AM CET, roopa@cumulusnetworks.com wrote:
>>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>>
>>>> This is a generic high level feature flag for all switch asic features
>>>> today.
>>>>
>>>> switch drivers set this flag on switch ports. Logical devices like
>>>> bridge, bonds, vxlans can inherit this flag from their slaves/ports.
>>>
>>> Can you please elaborate on how exactly would this inheritance look
>>> like?
>>
>> My thought there was, when a port with the hw offload flag is added to the
>> bridge, the same flag gets set on the bridge. And, for any bridge attributes
>> (not port attributes), this flag on the bridge can be used to offload those
>> bridge attributes.
>> bridge attribute examples: IFLA_BR_FORWARD_DELAY, IFLA_BR_HELLO_TIME,
>> IFLA_BR_MAX_AGE.
> Ah, wait, why do those need to be pushed down to driver/HW?  Letting
> the bridge (or external process like mstpd) own the ctrl-plane means
> HW isn't running STP machine or aging out FDB entries.  Let Linux take
> care of that.
>
> Same goes for bonding, since that was mentioned earlier.  Keep LACP
> ctrl processing in the kernel/bonding driver, and there is no need to
> push bonding settings down to port driver/hw.  driver/hw just need to
> know port membership and LACP status.

scott, agreed these are stp attributes. Wont go into hardware. I picked 
the wrong example.
But, I was just trying to point out that there maybe bridge attributes 
that need to be passed to hw.
Like the bridge ageing timer etc. We don't use it today. But others may 
in the future.
I was just trying to say that ...this maybe useful in the future. The 
current in-kernel implementation
nor my patches do anything for this. We can add it in the future if need 
be.
