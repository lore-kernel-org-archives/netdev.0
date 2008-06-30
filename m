From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 6/8] netfilter: fix string extension for case insensitive pattern matching
Date: Mon, 30 Jun 2008 11:44:58 -0700
Message-ID: <b25c3fa70806301144x4cd521dfpdd8bb6ef13b8466@mail.gmail.com>
References: <1214034858-1378-1-git-send-email-joonwpark81@gmail.com>
	 <alpine.LNX.1.10.0806210957140.28924@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Patrick McHardy" <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Thomas Graf" <tgraf@suug.ch>,
	"Pablo Neira Ayuso" <pablo@netfilter.org>
To: "Jan Engelhardt" <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:39042 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758298AbYF3So7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 14:44:59 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1815206rvb.1
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2008 11:44:58 -0700 (PDT)
In-Reply-To: <alpine.LNX.1.10.0806210957140.28924@fbirervta.pbzchgretzou.qr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/6/29 Jan Engelhardt <jengelh@medozas.de>:
>
> On Saturday 2008-06-21 09:54, Joonwoo Park wrote:
>
>>icase of xt_string_info indicates case [in]sensitive matching.
>>netfilter can find cmd.exe, Cmd.exe, cMd.exe and etc easily.
>>
>>Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
>>---
>> include/linux/netfilter/xt_string.h |    1 +
>> net/netfilter/xt_string.c           |    2 +-
>> 2 files changed, 2 insertions(+), 1 deletions(-)
>>
>>diff --git a/include/linux/netfilter/xt_string.h b/include/linux/netfilter/xt_string.h
>>index bb21dd1..dfd347f 100644
>>--- a/include/linux/netfilter/xt_string.h
>>+++ b/include/linux/netfilter/xt_string.h
>>@@ -12,6 +12,7 @@ struct xt_string_info
>>       char      pattern[XT_STRING_MAX_PATTERN_SIZE];
>>       u_int8_t  patlen;
>>       u_int8_t  invert;
>>+      u_int8_t  icase;
>>
>>       /* Used internally by the kernel */
>>       struct ts_config __attribute__((aligned(8))) *config;
>
> Why not just doing it this way?
>
>
> enum {
>        XT_STRING_INVERT = 1 << 0,
>        XT_STRING_ICASE  = 1 << 1,
> };
>
> struct xt_string_info {
>        ...
>        union {
>                uint8_t invert;
>                uint8_t flags;
>        };
>        ...
> };
>
>

Not bad for me,
I think invert might be removed and flags can contain XT_STRING_INVERT as well.
But I guess we should do version checking between user-space and
kernel more strictly whatever.
