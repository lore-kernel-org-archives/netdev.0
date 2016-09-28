From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC 3/6] net: phy: Threaded interrupts allow some
 simplification
Date: Wed, 28 Sep 2016 15:13:46 +0300
Message-ID: <af8f7c76-f2fe-95ac-4151-0189baf84a53@cogentembedded.com>
References: <1475051544-18561-1-git-send-email-andrew@lunn.ch>
 <1475051544-18561-4-git-send-email-andrew@lunn.ch>
 <7997d337-cd0f-ab39-1f53-df996063932b@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:36690 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753112AbcI1MNt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 08:13:49 -0400
Received: by mail-lf0-f48.google.com with SMTP id g62so49076963lfe.3
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 05:13:48 -0700 (PDT)
In-Reply-To: <7997d337-cd0f-ab39-1f53-df996063932b@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/28/2016 2:46 PM, Sergei Shtylyov wrote:

>> The PHY interrupts are now handled in a threaded interrupt handler,
>> which can sleep. The work queue is no longer needed, phy_change() can
>> be called directly. Additionally, none of the callers of
>> phy_mac_interrupt() did so in interrupt context, so fully remove the
>
>    I did intend to call it from interrupt context (from the ravb driver).
>
>> work queue, and document that phy_mac_interrupt() should not be called
>> in interrupt context.
>
>    It was intentionally made callable from the interrupt context, I'd prefer
> if you wouldn't change that.

    OTOH, it's still not very handy to call because of the 'new_link' 
parameter which I'm not sure I can provide...

>> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> [...]

MBR, Sergei
