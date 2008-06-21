From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 3/8] textsearch: fix Boyer-Moore algorithm for case insensitive searching
Date: Sat, 21 Jun 2008 02:17:26 -0700
Message-ID: <b25c3fa70806210217w48658acewc2f987414bd312c3@mail.gmail.com>
References: <1214034845-1316-1-git-send-email-joonwpark81@gmail.com>
	 <485CBAE4.4030307@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Pablo Neira Ayuso" <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <485CBAE4.4030307@trash.net>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2008/6/21 Patrick McHardy <kaber@trash.net>:
> Joonwoo Park wrote:
>>
>> @@ -75,7 +77,9 @@ static unsigned int bm_find(struct ts_config *conf,
>> struct ts_state *state)
>>                        DEBUGP("Searching in position %d (%c)\n",
>>                      shift, text[shift]);
>>                        for (i = 0; i < bm->patlen; i++) -
>>            if (text[shift-i] != bm->pattern[bm->patlen-1-i])
>> +                               if ((icase ? toupper(text[shift-i])
>> +                                   : text[shift-i])
>> +                                       != bm->pattern[bm->patlen-1-i])
>>                                     goto next;
>>                          /* London calling... */
>> @@ -111,14 +115,18 @@ static int subpattern(u8 *pattern, int i, int j, int
>> g)
>>        return ret;
>>  }
>>  -static void compute_prefix_tbl(struct ts_bm *bm)
>> +static void compute_prefix_tbl(struct ts_bm *bm, u8 icase)
>>  {
>>        int i, j, g;
>>          for (i = 0; i < ASIZE; i++)
>>                bm->bad_shift[i] = bm->patlen;
>> -       for (i = 0; i < bm->patlen - 1; i++)
>> +       for (i = 0; i < bm->patlen - 1; i++) {
>>                bm->bad_shift[bm->pattern[i]] = bm->patlen - 1 - i;
>> +               if (icase)
>> +                       bm->bad_shift[tolower(bm->pattern[i])]
>> +                           = bm->patlen - 1 - i;
>> +       }
>
> You use toupper() above and tolower() here, is that correct?
>

It should be, bm->pattern's characters are all upper case since It was
altered before.
So we should use toupper() for target string character to compare.
And to ignore case, we should prepare one more bad_shift array
calculation, opposite tolower() should be used for it.
