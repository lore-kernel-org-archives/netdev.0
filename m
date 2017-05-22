From: Arend van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: 4.12-RC2 BUG: scheduling while atomic: irq/47-iwlwifi
Date: Mon, 22 May 2017 14:09:53 +0200
Message-ID: <764a929c-ce8a-c859-a49e-2f20cb05ae44@broadcom.com>
References: <a54f3f4f-2365-2154-ad18-82e4cd572aac@eikelenboom.it>
 <1495450628.2653.14.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
        Sander Eikelenboom <linux@eikelenboom.it>,
        linux-wireless <linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f171.google.com ([209.85.128.171]:33030 "EHLO
        mail-wr0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758647AbdEVMKJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 08:10:09 -0400
Received: by mail-wr0-f171.google.com with SMTP id w50so37276878wrc.0
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 05:09:55 -0700 (PDT)
In-Reply-To: <1495450628.2653.14.camel@sipsolutions.net>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/22/2017 12:57 PM, Johannes Berg wrote:
> On Mon, 2017-05-22 at 12:36 +0200, Sander Eikelenboom wrote:
>> Hi,
>>
>> I encountered this splat with 4.12-RC2.
> 
> Ugh, yeah, I should've seen that in the review.
> 
> Arend, please take a look at this. cfg80211_sched_scan_results() cannot
> sleep, so you can't rtnl_lock() in there. Looks like you can just rely
> on RCU though?

I see. I think you are right on RCU. Don't have the code in front of me 
now, but I think the lookup has an ASSERT_RTNL. Will look into it after 
my monday meeting :-p

Regards,
Arend
