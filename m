From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 6/8] netfilter: fix string extension for case insensitive
 pattern matching
Date: Sun, 29 Jun 2008 16:29:53 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0806210957140.28924@fbirervta.pbzchgretzou.qr>
References: <> <1214034858-1378-1-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1214034858-1378-1-git-send-email-joonwpark81@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Saturday 2008-06-21 09:54, Joonwoo Park wrote:

>icase of xt_string_info indicates case [in]sensitive matching.
>netfilter can find cmd.exe, Cmd.exe, cMd.exe and etc easily.
>
>Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
>---
> include/linux/netfilter/xt_string.h |    1 +
> net/netfilter/xt_string.c           |    2 +-
> 2 files changed, 2 insertions(+), 1 deletions(-)
>
>diff --git a/include/linux/netfilter/xt_string.h b/include/linux/netfilter/xt_string.h
>index bb21dd1..dfd347f 100644
>--- a/include/linux/netfilter/xt_string.h
>+++ b/include/linux/netfilter/xt_string.h
>@@ -12,6 +12,7 @@ struct xt_string_info
> 	char 	  pattern[XT_STRING_MAX_PATTERN_SIZE];
> 	u_int8_t  patlen;
> 	u_int8_t  invert;
>+	u_int8_t  icase;
> 
> 	/* Used internally by the kernel */
> 	struct ts_config __attribute__((aligned(8))) *config;

Why not just doing it this way?


enum {
	XT_STRING_INVERT = 1 << 0,
	XT_STRING_ICASE  = 1 << 1,
};

struct xt_string_info {
	...
	union {
		uint8_t invert;
		uint8_t flags;
	};
	...
};

