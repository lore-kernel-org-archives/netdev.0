From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 1/3] net/dcb: Add IEEE QCN attribute
Date: Thu, 5 Mar 2015 08:53:43 +0200
Message-ID: <CAJ3xEMiXAMfDaYvAELVmhEuQd7+R-f9=kELHrMxTz7ksFGPQLQ@mail.gmail.com>
References: <1425473468-25969-1-git-send-email-ogerlitz@mellanox.com>
	<1425473468-25969-2-git-send-email-ogerlitz@mellanox.com>
	<54F73EA6.2030006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:35222 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754316AbbCEGxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 01:53:44 -0500
Received: by obbgq1 with SMTP id gq1so12066883obb.2
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 22:53:44 -0800 (PST)
In-Reply-To: <54F73EA6.2030006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 4, 2015 at 7:19 PM, John Fastabend <john.fastabend@gmail.com> wrote:
> On 03/04/2015 04:51 AM, Or Gerlitz wrote:
>>
>> From: Shani Michaeli <shanim@mellanox.com>
>>
>> As specified in 802.1Qau spec. Add this optional attribute to the
>> DCB netlink layer. To allow for application to use the new attribute,
>> NIC drivers should implement and register the  callbacks ieee_getqcn,
>> ieee_setqcn and ieee_getqcnstats.
>>
>> The QCN attribute holds a set of parameters for management, and
>> a set of statistics to provide informative data on Congestion-Control
>> defined by this spec.
>>
>> Signed-off-by: Shani Michaeli <shanim@mellanox.com>
>> Signed-off-by: Shachar Raindel <raindel@mellanox.com>
>> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

> Looks good to me. Do you have a QCN enabled switch? I looked at
> implementing this awhile ago but didn't have any switch support so
> I never did it.

I'l let Shachar to address the testing and the MIB questions.

> Also do you have a user space client to configure this? I would like
> it if someone wanted to add support to lldpad/dcbtool.

Sure, we have some netlink (python scripts) code to configure/read
this towards the kernel.


> [...]
>> +
>> +/* This structure contains the IEEE 802.1Qau QCN managed object.
>> + *
>> + *@rpg_enable: enable QCN RP
>> + *@rppp_max_rps: maximum number of RPs allowed for this CNPV on this port
>> + *@rpg_time_reset: time between rate increases if no CNMs received.
>> + *                given in u-seconds
>> + *@rpg_byte_reset: transmitted data between rate increases if no CNMs
>> received.
>> + *                given in Bytes
>> + *@rpg_threshold: The number of times rpByteStage or rpTimeStage can
>> count
>> + *                before RP rate control state machine advances states
>> + *@rpg_max_rate: the maxinun rate, in Mbits per second,
>> + *              at which an RP can transmit
>> + *@rpg_ai_rate: The rate, in Mbits per second,
>> + *             used to increase rpTargetRate in the RPR_ACTIVE_INCREASE
>> + *@rpg_hai_rate: The rate, in Mbits per second,
>> + *              used to increase rpTargetRate in the RPR_HYPER_INCREASE
>> state
>> + *@rpg_gd: Upon CNM receive, flow rate is limited to (Fb/Gd)*CurrentRate.
>> + *        rpgGd is given as log2(Gd), where Gd may only be powers of 2
>> + *@rpg_min_dec_fac: The minimum factor by which the current transmit rate
>> + *                 can be changed by reception of a CNM.
>> + *                 value is given as percentage (1-100)
>> + *@rpg_min_rate: The minimum value, in bits per second, for rate to limit
>> + *@cndd_state_machine: The state of the congestion notification domain
>> + *                    defense state machine, as defined by IEEE 802.3Qau
>> + *                    section 32.1.1. In the interior ready state,
>> + *                    the QCN capable hardware may add CN-TAG TLV to the
>> + *                    outgoing traffic, to specifically identify outgoing
>> + *                    flows.
>> + */
>
>
> I'm assuming this structure maps to an IEEE MIB?

yep, I guess so

> Its a rather large structure for a single netlink type but this seems
> to be how we built
> the dcbnl interface and if it does seem logical that the structure is
> one logical block, meaning you need to supply all fields.

> [...]
>> +       if (ops->ieee_getqcn) {
>> +               struct ieee_qcn qcn;

> you might consider adding a newline here it  is the best practice for
> new code although dcbnl has plenty of examples where it doesn't use
> this convention.

OK, will add this here and in the other places where used that practice.
