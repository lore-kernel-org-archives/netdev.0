From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 1/3] net/dcb: Add IEEE QCN attribute
Date: Thu, 05 Mar 2015 07:05:43 -0800
Message-ID: <54F870C7.4030707@gmail.com>
References: <1425473468-25969-1-git-send-email-ogerlitz@mellanox.com> <1425473468-25969-2-git-send-email-ogerlitz@mellanox.com> <54F73EA6.2030006@gmail.com> <CAJ3xEMiXAMfDaYvAELVmhEuQd7+R-f9=kELHrMxTz7ksFGPQLQ@mail.gmail.com> <AM3PR05MB0935C9AF7EDFA7F90F3CAC6EDC1F0@AM3PR05MB0935.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>
To: Shachar Raindel <raindel@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:44724 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755846AbbCEPGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 10:06:02 -0500
Received: by oifu20 with SMTP id u20so12116207oif.11
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 07:06:01 -0800 (PST)
In-Reply-To: <AM3PR05MB0935C9AF7EDFA7F90F3CAC6EDC1F0@AM3PR05MB0935.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>>
>>> Looks good to me. Do you have a QCN enabled switch? I looked at
>>> implementing this awhile ago but didn't have any switch support so
>>> I never did it.
>>
>> I'l let Shachar to address the testing and the MIB questions.
>
> The Mellanox SwitchX-2 IC supports QCN. We were testing our NICs both
> with this switch IC and using internal test fixtures where we were
> injecting congestion notification messages as raw Ethernet packets by
> another host.

ah great didn't know that switch supported QCN.

>
>>
>>> Also do you have a user space client to configure this? I would like
>>> it if someone wanted to add support to lldpad/dcbtool.
>>
>> Sure, we have some netlink (python scripts) code to configure/read
>> this towards the kernel.
>>
>>
>>> [...]

[...]

>>>
>>>
>>> I'm assuming this structure maps to an IEEE MIB?
>>
>> yep, I guess so
>
> The structures map to the IEEE MIB for QCN (part of IEEE 802.1Qau).
> The fields rppp_max_rps and cndd_state_machine are in different sections
> than the rest of the fields. However, it seems bit redundant to define a
> whole struct just for one field. The cndd_state_machine is not explicitly
> defined in the MIB, as the LLDP negotiation, which the standard assumes,
> is implemented by lldpad.
>
>>
>>> Its a rather large structure for a single netlink type but this seems
>>> to be how we built
>>> the dcbnl interface and if it does seem logical that the structure is
>>> one logical block, meaning you need to supply all fields.
>>
>
> This is the set of parameters defining how you will reduce or increase you
> TX rate upon receiving CNM from the network. I agree that it is a long list,
> but this is how the standard was written...

yep works for me. I was just checking my assumptions are correct and
admittedly being a bit lazy so I didn't pull up the spec myself.

Thanks,
John

[...]

-- 
John Fastabend         Intel Corporation
