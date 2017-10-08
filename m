From: Xiang Gao <qasdfgtyuiop@gmail.com>
Subject: Re: [PATCH] mac80211: aead api to reduce redundancy
Date: Sun, 8 Oct 2017 01:43:49 -0400
Message-ID: <CAMtaSwRU45ve71=H4C7cDQEHrkHg2=eMvXhYbe4HZGxsPRD+AQ@mail.gmail.com>
References: <20170926131945.3962-1-qasdfgtyuiop@gmail.com> <1506945898.25586.3.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36330 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750771AbdJHFoL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2017 01:44:11 -0400
In-Reply-To: <1506945898.25586.3.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johannes,

Thanks for your time on reviewing this. I will make changes following
your review. See details below.
By the way, I'm still struggling on how to run unit tests. It might
take time for me to make it run on my machine.

2017-10-02 8:04 GMT-04:00 Johannes Berg <johannes@sipsolutions.net>:
> Please use "v2" tag or so in the subject line, having the same patch
> again is really not helpful.
>
> The next should be v3, obviously.

Thanks for your patience to point this out. I will follow your instruction.

>
>> +++ b/net/mac80211/aead_api.c
>> @@ -1,7 +1,4 @@
>> -/*
>> - * Copyright 2014-2015, Qualcomm Atheros, Inc.
>> - *
>> - * This program is free software; you can redistribute it and/or
>> modify
>> +/* This program is free software; you can redistribute it and/or
>> modify
>
> I see no reason to make this change, why remove copyright?

Hmm... good question. The reason is, aes_ccm.c and aes_gcm.c was
almost exact copy of each other. But they have different copyright
information.
The copyright of aes_ccm.c was:

Copyright 2006, Devicescape Software, Inc.
Copyright 2003-2004, Instant802 Networks, Inc.

and the copyright of aes_gcm.c was:

Copyright 2014-2015, Qualcomm Atheros, Inc.

I just don't know how to write the copyright for the new aead_api.c,
so I does not put anything there.

These copyright information are still at aes_ccm.h and aes_gcm.h

What's your opinion on writing these copyright information? Do I write
all of them? like:

Copyright 2014-2015, Qualcomm Atheros, Inc.
Copyright 2006, Devicescape Software, Inc.
Copyright 2003-2004, Instant802 Networks, Inc.

>
>> +++ b/net/mac80211/wpa.c
>> @@ -464,7 +464,8 @@ static int ccmp_encrypt_skb(struct
>> ieee80211_tx_data *tx, struct sk_buff *skb,
>>       pos += IEEE80211_CCMP_HDR_LEN;
>>       ccmp_special_blocks(skb, pn, b_0, aad);
>>       return ieee80211_aes_ccm_encrypt(key->u.ccmp.tfm, b_0, aad,
>> pos, len,
>> -                                      skb_put(skb, mic_len),
>> mic_len);
>> +                                      skb_put(skb,
>> +                                              key->u.ccmp.tfm-
>> >authsize));
>>  }
>
> I see no reason for the change from mic_len to authsize here?

This was because I was planning to put it to crypto directory, then I
changed it to the same name as in other crypto api. Now that it will
goes to the mac80211, I think it is time to revert this change.

>
>> @@ -540,10 +541,11 @@ ieee80211_crypto_ccmp_decrypt(struct
>> ieee80211_rx_data *rx,
>>                       ccmp_special_blocks(skb, pn, b_0, aad);
>>
>>                       if (ieee80211_aes_ccm_decrypt(
>> -                                 key->u.ccmp.tfm, b_0, aad,
>> -                                 skb->data + hdrlen + IEEE80211_CCMP_HDR_LEN,
>> -                                 data_len,
>> -                                 skb->data + skb->len - mic_len, mic_len))
>> +                             key->u.ccmp.tfm, b_0, aad,
>> +                             skb->data + hdrlen + IEEE80211_CCMP_HDR_LEN,
>> +                             data_len,
>> +                             skb->data + skb->len - key->u.ccmp.tfm->authsize
>> +                     ))
>>                               return RX_DROP_UNUSABLE;
>
> That's a really really strange way of writing this ...
>
> Please reformat.

OK, I will reformat it.

>
> johannes
