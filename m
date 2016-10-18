From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC 3/6] net: phy: Threaded interrupts allow some
 simplification
Date: Tue, 18 Oct 2016 13:37:11 +0300
Message-ID: <a3e6b467-9e44-1ed5-65ce-63c839dd3365@cogentembedded.com>
References: <1475051544-18561-1-git-send-email-andrew@lunn.ch>
 <1475051544-18561-4-git-send-email-andrew@lunn.ch>
 <7997d337-cd0f-ab39-1f53-df996063932b@cogentembedded.com>
 <af8f7c76-f2fe-95ac-4151-0189baf84a53@cogentembedded.com>
 <20160928122835.GB22809@lunn.ch>
 <891f6b60-47a0-ba03-d6d3-8284993d1896@cogentembedded.com>
 <06bdfcb4-8bb6-28e6-00e5-2518f79f729d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33222 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752803AbcJRKhN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 06:37:13 -0400
Received: by mail-lf0-f47.google.com with SMTP id x79so348643553lff.0
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 03:37:13 -0700 (PDT)
In-Reply-To: <06bdfcb4-8bb6-28e6-00e5-2518f79f729d@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 9/28/2016 8:14 PM, Florian Fainelli wrote:

>>>>>> The PHY interrupts are now handled in a threaded interrupt handler,
>>>>>> which can sleep. The work queue is no longer needed, phy_change() can
>>>>>> be called directly. Additionally, none of the callers of
>>>>>> phy_mac_interrupt() did so in interrupt context, so fully remove the
>>>>>
>>>>>   I did intend to call it from interrupt context (from the ravb
>>>>> driver).
>>>>>
>>>>>> work queue, and document that phy_mac_interrupt() should not be called
>>>>>> in interrupt context.
>>>>>
>>>>>   It was intentionally made callable from the interrupt context, I'd
>>>>> prefer
>>>>> if you wouldn't change that.
>>>>
>>>>    OTOH, it's still not very handy to call because of the 'new_link'
>>>> parameter which I'm not sure I can provide...
>>>
>>> Hi Sergei
>>>
>>> If there is a need for it, i will leave the work queue and keep this
>>> code unchanged.
>>
>>    Let's hear what Florian says...
>
> The intent is really to have phy_mac_interrupt() callable from hard IRQ
> context, not that this matters really too much because link events
> already occur in the slow path, but it's nice to have that property
> retained IMHO.

    Actually, I still don't know how to call phy_mac_interrupt() from the ravb 
driver because of the 'new_link' parameter -- I won't always have that signal 
connected to the MAC...

MBR, Sergei
