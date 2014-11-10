From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net] udptunnel: Add SKB_GSO_UDP_TUNNEL during gro_complete.
Date: Mon, 10 Nov 2014 11:45:57 -0800
Message-ID: <CAEP_g=9TzDFwgFKynXXJKGYrnKJ8xNHAg0zSX9+D1rCpO9umzw@mail.gmail.com>
References: <1415391969-108511-1-git-send-email-jesse@nicira.com>
 <28743.1415411491@famine> <CAEP_g=9Z4_xOnPJDcxGgSPvw1Heu5FGrij_L5Xbi6FeFfAwLvQ@mail.gmail.com>
 <20141110.143348.968744105996557913.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog021.obsmtp.com ([74.125.150.82]:51035 "HELO
	na6sys009bog021.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750833AbaKJTqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 14:46:19 -0500
Received: by mail-qa0-f51.google.com with SMTP id f12so5900257qad.10
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 11:46:18 -0800 (PST)
In-Reply-To: <20141110.143348.968744105996557913.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 10, 2014 at 11:33 AM, David Miller <davem@davemloft.net> wrote:
> From: Jesse Gross <jesse@nicira.com>
> Date: Fri, 7 Nov 2014 19:54:51 -0800
>
>> On Fri, Nov 7, 2014 at 5:51 PM, Jay Vosburgh <jay.vosburgh@canonical.com> wrote:
>>> Jesse Gross <jesse@nicira.com> wrote:
>>>
>>>>When doing GRO processing for UDP tunnels, we never add
>>>>SKB_GSO_UDP_TUNNEL to gso_type - only the type of the inner protocol
>>>>is added (such as SKB_GSO_TCPV4). The result is that if the packet is
>>>>later resegmented we will do GSO but not treat it as a tunnel. This
>>>>results in UDP fragmentation and since that is not the original layout
>>>>of the skb, a panic in skb_segment().
>>>>
>>>>Reported-by: Jay Vosburgh <jay.vosburgh@canonical.com>
>>>>Signed-off-by: Jesse Gross <jesse@nicira.com>
>>>>---
>>>>This problem occurs back to 3.14 for VXLAN but the FOU portion needs to
>>>>be removed for kernels other than the 'net' tree.
>>>
>>>         This patch does not resolve the problem when applied to a
>>> 3.17-ish kernel; the panic message is below, and appears to be
>>> unchanged.
>>
>> Hmm, OK, thanks for testing. I think this patch is probably still good
>> to apply as it may solve a problem after we get this one figured out.
>
> But if you want that to happen, you'll have to adjust the commit
> message because it doesn't fix the crash reported by Jay at all.

Sure, I've resent it with a new commit message.
