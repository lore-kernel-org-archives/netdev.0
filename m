From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next 09/13] bnx2x: add pri_map module parameter
Date: Thu, 10 Nov 2011 12:34:50 -0800
Message-ID: <4EBC356A.6020907@intel.com>
References: <1320938054-31288-1-git-send-email-dmitry@broadcom.com> <1320938054-31288-10-git-send-email-dmitry@broadcom.com> <1320946787.2851.2.camel@bwh-desktop> <CAM8tLiMATfsH1mqmgrALX9o+5nWEahntCAc2ewm0RF_kbt=82A@mail.gmail.com> <CAM8tLiN=E2=a0TEYgw6mc70-vJU0dHjP4F4PpKUk8+3zvQPnAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Dmitry Kravkov <dkravkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51691 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754087Ab1KJUex (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Nov 2011 15:34:53 -0500
In-Reply-To: <CAM8tLiN=E2=a0TEYgw6mc70-vJU0dHjP4F4PpKUk8+3zvQPnAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/2011 12:21 PM, Dmitry Kravkov wrote:
> Resending for netdev
> On Thu, Nov 10, 2011 at 10:18 PM, Dmitry Kravkov <dkravkov@gmail.com> wrote:
>>
>> On Thu, Nov 10, 2011 at 7:39 PM, Ben Hutchings <bhutchings@solarflare.com> wrote:
>>>
>>> On Thu, 2011-11-10 at 17:14 +0200, Dmitry Kravkov wrote:
>>>> From: Ariel Elior <ariele@broadcom.com>
>>>>
>>>> The optional parameter pri_map is used to map the
>>>> skb->priority to a Class Of Service (CoS) in the HW.
>>>> This 32 bit parameter is evaluated by the  driver as 8
>>>> values of 4 bits each. Each nibble sets the desired
>>>> HW queue number for that priority.
>>> [...]
>>>
>>> You should implement ndo_tc_setup instead of adding a driver-specific
>>> parameter (that should be per-device anyway).
>>
>> bnx2x has ndo_setup_tc, but the callback configures device for number of traffic
>> only, when actual mapping of priority to cos is done according to DCB negotiation.
>> The parameter allow user to force mapping if the link partner is not DCB capable.
>>
> --

Use 'tc' to configure the mapping explicitly then. Or allow DCBnl
set commands to be sent down either ieee_setets() or setpgtccfgtx()
are used to configure priority to traffic class mappings. Then you
could use a user space tool to set up all your DCB attributes without
DCBX running (e.g. dcbtool/lldptol but I'm partial).

For example 'tc' commands,

# tc qdisc add dev eth3 root mqprio map 0 1 2 3 
# tc qdisc add dev eth3 root mqprio help
Usage: ... mqprio [num_tc NUMBER] [map P0 P1 ...]
                  [queues count1@offset1 count2@offset2 ...] [hw 1|0]

It might be nice to add the ability to change the mapping after the tc
has been created though. Maybe I'll get to this in the next week or
two.

John.
