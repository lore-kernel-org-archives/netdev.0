From: John Heffner <jheffner@psc.edu>
Subject: [PATCH] Re: a question on tcp_highspeed.c (in 2.6.16)
Date: Thu, 04 May 2006 15:06:00 -0400
Message-ID: <445A5098.6010306@psc.edu>
References: <7335583a0605040703x1d6e8a20n515b22241795d3ab@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050505090007070109080808"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:56010 "EHLO mailer1.psc.edu")
	by vger.kernel.org with ESMTP id S1750803AbWEDTGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 May 2006 15:06:13 -0400
To: "Xiaoliang (David) Wei" <davidwei79@gmail.com>
In-Reply-To: <7335583a0605040703x1d6e8a20n515b22241795d3ab@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050505090007070109080808
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Xiaoliang (David) Wei wrote:
> Hi gurus,
> 
>    I am reading the code of tcp_highspeed.c in the kernel and have a
> question on the hstcp_cong_avoid function, specifically the following
> AI part (line 136~143 in net/ipv4/tcp_highspeed.c ):
> 
>                /* Do additive increase */
>                if (tp->snd_cwnd < tp->snd_cwnd_clamp) {
>                        tp->snd_cwnd_cnt += ca->ai;
>                        if (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
>                                tp->snd_cwnd++;
>                                tp->snd_cwnd_cnt -= tp->snd_cwnd;
>                        }
>                }
> 
>    In this part, when (tp->snd_cwnd_cnt == tp->snd_cwnd),
> snd_cwnd_cnt will be -1... snd_cwnd_cnt is defined as u16, will this
> small chance of getting -1 becomes a problem?
> Shall we change it by reversing the order of the cwnd++ and cwnd_cnt -= 
> cwnd?

Absolutely correct.  Thanks.

Signed-off-by: John Heffner <jheffner@psc.edu>

--------------050505090007070109080808
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="highspeed_cwnd_cnt.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="highspeed_cwnd_cnt.patch"

diff --git a/net/ipv4/tcp_highspeed.c b/net/ipv4/tcp_highspeed.c
index e0e9d13..b72fa55 100644
--- a/net/ipv4/tcp_highspeed.c
+++ b/net/ipv4/tcp_highspeed.c
@@ -137,8 +137,8 @@ static void hstcp_cong_avoid(struct sock
 		if (tp->snd_cwnd < tp->snd_cwnd_clamp) {
 			tp->snd_cwnd_cnt += ca->ai;
 			if (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
-				tp->snd_cwnd++;
 				tp->snd_cwnd_cnt -= tp->snd_cwnd;
+				tp->snd_cwnd++;
 			}
 		}
 	}

--------------050505090007070109080808--
