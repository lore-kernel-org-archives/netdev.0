From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 6/8] netfilter: fix string extension for case insensitive
 pattern matching
Date: Mon, 30 Jun 2008 21:09:12 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0806302108290.30639@fbirervta.pbzchgretzou.qr>
References: <1214034858-1378-1-git-send-email-joonwpark81@gmail.com>  <alpine.LNX.1.10.0806210957140.28924@fbirervta.pbzchgretzou.qr> <b25c3fa70806301144x4cd521dfpdd8bb6ef13b8466@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <b25c3fa70806301144x4cd521dfpdd8bb6ef13b8466@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Monday 2008-06-30 20:44, Joonwoo Park wrote:
>> Why not just doing it this way?
>>
>>
>> enum {
>>        XT_STRING_INVERT = 1 << 0,
>>        XT_STRING_ICASE  = 1 << 1,
>> };
>>
>> struct xt_string_info {
>>        ...
>>        union {
>>                uint8_t invert;
>>                uint8_t flags;
>>        };
>>        ...
>> };
>>
>>
>
>Not bad for me,
>I think invert might be removed and flags can contain XT_STRING_INVERT as well.

Right, since we copy eader files anyway, we can just make it uint8_t flags
without the union.

>But I guess we should do version checking between user-space and
>kernel more strictly whatever.

That is what we have '.revision' in xt_match/xt_target for.
In this case however it should be fine with just flags.
