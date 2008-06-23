From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/8] textsearch: fix Boyer-Moore algorithm for case insensitive
 searching
Date: Mon, 23 Jun 2008 13:33:39 +0200
Message-ID: <485F8A13.90808@trash.net>
References: <1214034845-1316-1-git-send-email-joonwpark81@gmail.com>	 <485CBAE4.4030307@trash.net> <b25c3fa70806210217w48658acewc2f987414bd312c3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46087 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752541AbYFWLdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 07:33:43 -0400
In-Reply-To: <b25c3fa70806210217w48658acewc2f987414bd312c3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joonwoo Park wrote:
> 2008/6/21 Patrick McHardy <kaber@trash.net>:
>>> +static void compute_prefix_tbl(struct ts_bm *bm, u8 icase)
>>>  {
>>>        int i, j, g;
>>>          for (i = 0; i < ASIZE; i++)
>>>                bm->bad_shift[i] = bm->patlen;
>>> -       for (i = 0; i < bm->patlen - 1; i++)
>>> +       for (i = 0; i < bm->patlen - 1; i++) {
>>>                bm->bad_shift[bm->pattern[i]] = bm->patlen - 1 - i;
>>> +               if (icase)
>>> +                       bm->bad_shift[tolower(bm->pattern[i])]
>>> +                           = bm->patlen - 1 - i;
>>> +       }
>> You use toupper() above and tolower() here, is that correct?
>>
> 
> It should be, bm->pattern's characters are all upper case since It was
> altered before.
> So we should use toupper() for target string character to compare.
> And to ignore case, we should prepare one more bad_shift array
> calculation, opposite tolower() should be used for it.

OK thanks. I'll wait for an ACK from Thomas before applying
them though.

