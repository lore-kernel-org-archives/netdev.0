From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] sk-filter:  Rate-limit WARNing, print dbg info.
Date: Tue, 17 May 2011 11:52:29 -0700
Message-ID: <1305658349.1722.30.camel@Joe-Laptop>
References: <1305657014-32736-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1716 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756235Ab1EQSwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 14:52:31 -0400
In-Reply-To: <1305657014-32736-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-17 at 11:30 -0700, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
> A mis-configured filter can spam the logs with
> lots of stack traces.  Rate-limit the warnings
> and add printout of the bogus filter information.
> -			WARN_ON(1);
> +			if (net_ratelimit()) {
> +				pr_err("filter: Unknown code: %hu jt: %u tf: %u"
> +				       " k: %u\n",
> +				       fentry->code, (unsigned int)(fentry->jt),
> +				       (unsigned int)(fentry->jf), fentry->k);
> +				WARN_ON(1);
> +			}

Maybe just using WARN is better.
I believe the casts aren't necessary.

 net/core/filter.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 0eb8c44..5b967d0 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -350,7 +350,10 @@ load_b:
 			continue;
 		}
 		default:
-			WARN_ON(1);
+			if (net_ratelimit())
+				WARN(1, "Unknown code:%u jt:%u tf:%u k:%u\n",
+				     fentry->code, fentry->jt,
+				     fentry->jf, fentry->k);
 			return 0;
 		}
 	}


