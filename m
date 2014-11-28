From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 08/17] bridge: call netdev_sw_port_stp_update
 when bridge port STP status changes
Date: Fri, 28 Nov 2014 14:27:09 +0100
Message-ID: <20141128132709.GB1877@nanopsycho.orion>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-9-git-send-email-jiri@resnulli.us>
 <5475073E.70503@cumulusnetworks.com>
 <CAE4R7bAiEyztdGo2BMVGXq9phfASHsMU+QW4oocTmr9=4antxw@mail.gmail.com>
 <547848D8.1060203@cumulusnetworks.com>
 <CAE4R7bCfi-90pccDJN350bdeQi2R4H5Xbu3-BADZ29vWhfkJiA@mail.gmail.com>
 <547875F1.9080204@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>,
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
	John Linville <linville@tuxd
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:47696 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbaK1N1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 08:27:12 -0500
Received: by mail-wg0-f53.google.com with SMTP id l18so8703905wgh.26
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2014 05:27:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <547875F1.9080204@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Nov 28, 2014 at 02:17:37PM CET, jhs@mojatatu.com wrote:
>On 11/28/14 05:51, Scott Feldman wrote:
>>On Fri, Nov 28, 2014 at 2:05 AM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>>>On 11/25/14, 5:35 PM, Scott Feldman wrote:
>>>>
>>>>   The
>>>>bridge driver or external STP process (msptd) is still controlling STP
>>>>state for the port and processing the BPDUs.  When the state changes
>>>>on the port, the bridge driver is letting HW know, that's it.
>>>
>>>
>>>I understand that. In which case, we should not call it stp state.
>>>It is just port state.
>>
>>Sure, call it port state but it takes on BR_STATE_xxx values which
>>just so happen to correspond exactly to STP states.
>>
>>>And since it is yet another port attribute like port
>>>priority,
>>>we should be able to use the same api to offload it to hw just like the
>>>other port attributes.
>>
>>Well it does...see ndo_bridge_setlink in bridge driver, br_setport
>>where IFLA_BRPORT_STATE is handled...it calls br_set_port_state(),
>>which calls into the swdev port driver.  That's for the case where
>>user or external processing is setting STP state.  For the case where
>>the bridge itself is managing the STP state, the bridge will make the
>>same br_set_port_state() call to adjust the port state.
>>
>
>What Roopa is requesting for if i am not mistaken is the same issue i
>raised earlier as well. We need an opaque way to set and get these
>attributes. We cant afford an ndo ops per bridge or the next thing.
>Its a port level issue - what it is depends on what the underlying
>hardware does.

I agree. This will be addressed (it's in the etherpad todo).

>
>cheers,
>jamal
>
