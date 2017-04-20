From: James Hughes <james.hughes@raspberrypi.org>
Subject: Re: [PATCH] brcm80211: brcmfmac: Ensure that incoming skb's are writable
Date: Thu, 20 Apr 2017 13:09:20 +0100
Message-ID: <CAE_XsMJGpKKdZ4E90tkzYwe+7KJ8JB5Rwrzga6aUi1LZG+wH4w@mail.gmail.com>
References: <20170420111651.10213-1-james.hughes@raspberrypi.org> <87y3uv48nv.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        linux-wireless@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00252a01.pphosted.com ([62.209.51.214]:47373 "EHLO
        mx07-00252a01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S969221AbdDTMJX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 08:09:23 -0400
Received: from pps.filterd (m0102628.ppops.net [127.0.0.1])
        by mx07-00252a01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3KC9L3Y002202
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 13:09:21 +0100
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
        by mx07-00252a01.pphosted.com with ESMTP id 29wqp2rta0-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=OK)
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 13:09:21 +0100
Received: by mail-wr0-f198.google.com with SMTP id v6so5401378wrc.21
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 05:09:21 -0700 (PDT)
In-Reply-To: <87y3uv48nv.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20 April 2017 at 12:31, Kalle Valo <kvalo@codeaurora.org> wrote:
> + linux-wireless
>
> James Hughes <james.hughes@raspberrypi.org> writes:
>
>> The driver was adding header information to incoming skb
>> without ensuring the head was uncloned and hence writable.
>>
>> skb_cow_head has been used to ensure they are writable, however,
>> this required some changes to error handling to ensure that
>> if skb_cow_head failed it was not ignored.
>>
>> This really needs to be reviewed by someone who is more familiar
>> with this code base to ensure any deallocation of skb's is
>> still correct.
>>
>> Signed-off-by: James Hughes <james.hughes@raspberrypi.org>
>
> You should also CC linux-wireless, otherwise patchwork won't see it.
>
> --
> Kalle Valo

Thanks Kalle, I wasn't subscribed to wireless, but have now done so. I
also failed to read the MAINTAINERS list correctly..

With regard to this particular patch, this is related to the recent
patches to use skb_cow_head in a number of USB net drivers to ensure
they can write headers correctly, and I suspect the same fault is
possible/likely in other drivers outside the USB net realm, as this
patch shows.

I'm not overly happy with the error handling in this patch, but that
said, the error handling over this entire driver does strike me as
suspect. Quite a few places where return codes are ignored, just in my
quick examination. So not really sure how to proceed past this patch,
if at all.
