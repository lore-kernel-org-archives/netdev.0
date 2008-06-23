From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 3/8] textsearch: fix Boyer-Moore algorithm for case insensitive searching
Date: Mon, 23 Jun 2008 13:41:54 -0700
Message-ID: <b25c3fa70806231341u5ccb39f1n53af4c05bea92027@mail.gmail.com>
References: <1214034845-1316-1-git-send-email-joonwpark81@gmail.com>
	 <485CBAE4.4030307@trash.net>
	 <b25c3fa70806210217w48658acewc2f987414bd312c3@mail.gmail.com>
	 <485F8A13.90808@trash.net> <485F96A6.20904@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Patrick McHardy" <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Thomas Graf" <tgraf@suug.ch>
To: "Pablo Neira Ayuso" <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:60852 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756927AbYFWUly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 16:41:54 -0400
Received: by rv-out-0506.google.com with SMTP id k40so7255643rvb.1
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 13:41:54 -0700 (PDT)
In-Reply-To: <485F96A6.20904@netfilter.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/6/23 Pablo Neira Ayuso <pablo@netfilter.org>:
> Patrick McHardy wrote:
>> Joonwoo Park wrote:
>>> 2008/6/21 Patrick McHardy <kaber@trash.net>:
>>>>> +static void compute_prefix_tbl(struct ts_bm *bm, u8 icase)
>>>>>  {
>>>>>        int i, j, g;
>>>>>          for (i = 0; i < ASIZE; i++)
>>>>>                bm->bad_shift[i] = bm->patlen;
>>>>> -       for (i = 0; i < bm->patlen - 1; i++)
>>>>> +       for (i = 0; i < bm->patlen - 1; i++) {
>>>>>                bm->bad_shift[bm->pattern[i]] = bm->patlen - 1 - i;
>>>>> +               if (icase)
>>>>> +                       bm->bad_shift[tolower(bm->pattern[i])]
>>>>> +                           = bm->patlen - 1 - i;
>>>>> +       }
>>>> You use toupper() above and tolower() here, is that correct?
>>>>
>>>
>>> It should be, bm->pattern's characters are all upper case since It was
>>> altered before.
>>> So we should use toupper() for target string character to compare.
>>> And to ignore case, we should prepare one more bad_shift array
>>> calculation, opposite tolower() should be used for it.
>>
>> OK thanks. I'll wait for an ACK from Thomas before applying
>> them though.
>
> This is rather confusing. Why not set both the pattern and the bad_shift
> to lower or upper case?
>

To be honest, pattern can be set to lower or upper case, it doesn't matter.
But for bad_shift, we should add one more array for diffrence of case.
So bad_shift array should have both of lower and upper.

>>>>> +       for (i = 0; i < bm->patlen - 1; i++) {
>>>>>                bm->bad_shift[bm->pattern[i]] = bm->patlen - 1 - i;

Therefore, at here, this makes bad_shift for upper case,

>>>>> +               if (icase)
>>>>> +                       bm->bad_shift[tolower(bm->pattern[i])]
>>>>> +                           = bm->patlen - 1 - i;

At here, this makes bad_shift for lower case.
