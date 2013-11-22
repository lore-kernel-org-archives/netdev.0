From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [ovs-dev] [PATCH openvswitch] linux: Signal datapath that unaligned
 Netlink message can be received
Date: Fri, 22 Nov 2013 19:41:33 +0400
Message-ID: <528F7B2D.1060105@cogentembedded.com>
References: <48c93fb3c82bca0c9858ff528e2cf79d72d76082.1385057672.git.tgraf@redhat.com> <528E559C.4020201@cogentembedded.com> <20131121205208.GA24729@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@redhat.com>, jesse@nicira.com,
	dev@openvswitch.org, netdev@vger.kernel.org
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:38448 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755334Ab3KVPlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 10:41:36 -0500
Received: by mail-lb0-f173.google.com with SMTP id u14so1073692lbd.18
        for <netdev@vger.kernel.org>; Fri, 22 Nov 2013 07:41:34 -0800 (PST)
In-Reply-To: <20131121205208.GA24729@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 22-11-2013 0:52, Ben Pfaff wrote:

>>> Following commit (''netlink: Do not enforce alignment of last Netlink
>>> attribute''), signal the ability to receive unaligned Netlink messages
>>> to the datapath to enable utilization of zerocopy optimizations.

>>> Signed-off-by: Thomas Graf <tgraf@redhat.com>
>> [...]

>>> diff --git a/lib/dpif-linux.c b/lib/dpif-linux.c
>>> index 1dcf321..5c952bc 100644
>>> --- a/lib/dpif-linux.c
>>> +++ b/lib/dpif-linux.c
>> [...]
>>> @@ -1839,6 +1841,10 @@ dpif_linux_dp_to_ofpbuf(const struct dpif_linux_dp *dp, struct ofpbuf *buf)
>>>           nl_msg_put_u32(buf, OVS_DP_ATTR_UPCALL_PID, *dp->upcall_pid);
>>>       }
>>>
>>> +    if (dp->user_features) {
>>> +        nl_msg_put_u32(buf, OVS_DP_ATTR_USER_FEATURES, dp->user_features);
>>> +    }
>>> +
>>
>>     {} not needed here.

> This is Open vSwitch code,

    I didn't put much attention at the file name or subject but the issue 
seemed just too obvious...

> so it follows Open vSwitch coding style,
> which requires the {}.

    Strange style. Oh well... :-)

WBR, Sergei
