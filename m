From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCH] openvswitch: Add cutlen info to upcall.
Date: Thu, 16 Jun 2016 07:28:22 -0700
Message-ID: <CALDO+SZAYACM2An88EMLRsYY+xubDRs6fD4CGfNowQ9XfrNxTQ@mail.gmail.com>
References: <1466044135-9707-1-git-send-email-u9012063@gmail.com> <CAOrHB_CNe19U8wSOEAc6zi1+83ZH8GNQ3D+H_syG2SWNS5eUhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36229 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754943AbcFPO3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 10:29:02 -0400
Received: by mail-it0-f68.google.com with SMTP id h190so7305748ith.3
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 07:29:02 -0700 (PDT)
In-Reply-To: <CAOrHB_CNe19U8wSOEAc6zi1+83ZH8GNQ3D+H_syG2SWNS5eUhA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pravin,

Yes, I think that's better. Instead of cutlen, I will pass the
skb->len to userspace.

Regards,
William

On Wed, Jun 15, 2016 at 7:55 PM, pravin shelar <pshelar@ovn.org> wrote:
> On Wed, Jun 15, 2016 at 7:28 PM, William Tu <u9012063@gmail.com> wrote:
>> The commit f2a4d086ed4c ("openvswitch: Add packet truncation support.")
>> introduces packet truncation before sending to userspace upcall receiver.
>> This patch passes the number of bytes truncated in kernel to so that the
>> upcall receiver knows the original packet size. Potentially this will
>> be used by sFlow, where OVS translates sFlow config header=N to a sample
>> action to trunc(N) in kernel datapath. Thus, only N bytes instead of
>> full-packet size will be copied from kernel to userspace, saving the
>> kernel-to-userspace bandwidth.
>>
>> Signed-off-by: William Tu <u9012063@gmail.com>
>> Cc: Pravin Shelar <pshelar@nicira.com>
>
> This is passing unnecessary kernel implementation details to
> userspace, can we just pass skb-len to userspace?
