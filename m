From: Dmitry Kravkov <dkravkov@gmail.com>
Subject: Re: GREv4 ipv6 is broken for UDP stream on 3.9
Date: Thu, 30 May 2013 20:36:04 +0300
Message-ID: <CAM8tLiMQtSBjZv5Ojt1OVSrffT88Gn5KrEcKtROXjyLXnbQPtg@mail.gmail.com>
References: <CAM8tLiOQq2a_Z=F_V5A2saPN+JfwN7Ey29r+UmUK_f9oYF5vCw@mail.gmail.com>
	<CALnjE+pHEqdZ9KADF9L+8WfGwi+q-NgXSR7bnEiz4BhArY7q-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f170.google.com ([209.85.128.170]:47905 "EHLO
	mail-ve0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965407Ab3E3RgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 13:36:06 -0400
Received: by mail-ve0-f170.google.com with SMTP id 14so416310vea.15
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 10:36:05 -0700 (PDT)
In-Reply-To: <CALnjE+pHEqdZ9KADF9L+8WfGwi+q-NgXSR7bnEiz4BhArY7q-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 30, 2013 at 7:46 PM, Pravin Shelar <pshelar@nicira.com> wrote:
> I sent out fix "udp6: Fix udp fragmentation for tunnel traffic."
> Can you give it a try ?

Sure! Stay tuned...

>
> Thanks.
>
> On Wed, May 29, 2013 at 1:16 AM, Dmitry Kravkov <dkravkov@gmail.com> wrote:
>> Hi,
>>
>> since 3.9-rc1 i see that rx side drops all data packets for:
>>
>> netperf -6 -t UDP_STREAM -H fe80::5efe:c0a8:630c%gre_7 -l 1
>>
>> when gre_7 is:
>>
>> 13: gre_7: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1476 qdisc noqueue state UNKNOWN
>>     link/gre 192.168.99.29 peer 192.168.99.12
>>
>> The packets just gets corrupted.
>>
>> This bisected to:
>> commit 68c331631143f5f039baac99a650e0b9e1ea02b6
>> Author: Pravin B Shelar <pshelar@nicira.com>
>> Date:   Thu Feb 14 14:02:41 2013 +0000
>>
>>     v4 GRE: Add TCP segmentation offload for GRE
>>
>> Looks like gre_gso_segment build wrong segments for GSO flow.



--
Best regards,
Dmitry
