From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 08/17] bridge: call netdev_sw_port_stp_update
 when bridge port STP status changes
Date: Fri, 28 Nov 2014 08:17:37 -0500
Message-ID: <547875F1.9080204@mojatatu.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>	<1416911328-10979-9-git-send-email-jiri@resnulli.us>	<5475073E.70503@cumulusnetworks.com>	<CAE4R7bAiEyztdGo2BMVGXq9phfASHsMU+QW4oocTmr9=4antxw@mail.gmail.com>	<547848D8.1060203@cumulusnetworks.com> <CAE4R7bCfi-90pccDJN350bdeQi2R4H5Xbu3-BADZ29vWhfkJiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Linville <linville@tuxdriver.com>,
	"jasowang@redhat.com" <jasowang@red
To: Scott Feldman <sfeldma@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:41876 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901AbaK1NRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 08:17:41 -0500
Received: by mail-ig0-f172.google.com with SMTP id hl2so9855707igb.17
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2014 05:17:41 -0800 (PST)
In-Reply-To: <CAE4R7bCfi-90pccDJN350bdeQi2R4H5Xbu3-BADZ29vWhfkJiA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/14 05:51, Scott Feldman wrote:
> On Fri, Nov 28, 2014 at 2:05 AM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>> On 11/25/14, 5:35 PM, Scott Feldman wrote:
>>>
>>>    The
>>> bridge driver or external STP process (msptd) is still controlling STP
>>> state for the port and processing the BPDUs.  When the state changes
>>> on the port, the bridge driver is letting HW know, that's it.
>>
>>
>> I understand that. In which case, we should not call it stp state.
>> It is just port state.
>
> Sure, call it port state but it takes on BR_STATE_xxx values which
> just so happen to correspond exactly to STP states.
>
>> And since it is yet another port attribute like port
>> priority,
>> we should be able to use the same api to offload it to hw just like the
>> other port attributes.
>
> Well it does...see ndo_bridge_setlink in bridge driver, br_setport
> where IFLA_BRPORT_STATE is handled...it calls br_set_port_state(),
> which calls into the swdev port driver.  That's for the case where
> user or external processing is setting STP state.  For the case where
> the bridge itself is managing the STP state, the bridge will make the
> same br_set_port_state() call to adjust the port state.
>

What Roopa is requesting for if i am not mistaken is the same issue i
raised earlier as well. We need an opaque way to set and get these
attributes. We cant afford an ndo ops per bridge or the next thing.
Its a port level issue - what it is depends on what the underlying
hardware does.

cheers,
jamal
