From: "Satoru SATOH" <satoru.satoh@gmail.com>
Subject: Re: [PATCH] [IPROUTE]: A workaround to make larger rto_min printed correctly
Date: Fri, 21 Dec 2007 11:24:54 +0900
Message-ID: <d72b7ace0712201824k3754962cse377256cb5452b8a@mail.gmail.com>
References: <d72b7ace0712191931w37f02645u8d5eb5eef9c1fba4@mail.gmail.com>
	 <20071220091230.GB1924@ff.dom.local>
	 <d72b7ace0712200821k7cde0834rf1187b30c68cd1ce@mail.gmail.com>
	 <476ACF8A.7060201@gmail.com> <476AD127.2020909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.237]:42937 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751476AbXLUCY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 21:24:56 -0500
Received: by nz-out-0506.google.com with SMTP id s18so104946nze.1
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2007 18:24:55 -0800 (PST)
In-Reply-To: <476AD127.2020909@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2007/12/21, Jarek Poplawski <jarkao2@gmail.com>:
> Jarek Poplawski wrote, On 12/20/2007 09:24 PM:
> ...
>
> > but since it's your patch, I hope you do some additional checking
> > if it's always like this...
>
>
> ...or maybe only changing this all a little bit will make it look safer!
>
> Jarek P.


OK, how about this?

Signed-off-by: Satoru SATOH <satoru.satoh@gmail.com>

 ip/iproute.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index f4200ae..c771b34 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -510,16 +510,20 @@ int print_route(const struct sockaddr_nl *who,
struct nlmsghdr *n, void *arg)
 				fprintf(fp, " %u", *(unsigned*)RTA_DATA(mxrta[i]));
 			else {
 				unsigned val = *(unsigned*)RTA_DATA(mxrta[i]);
+				unsigned hz1 = hz;
+				if (hz1 > 1000)
+					hz1 /= 1000;
+				else
+					val *= 1000;

-				val *= 1000;
 				if (i == RTAX_RTT)
 					val /= 8;
 				else if (i == RTAX_RTTVAR)
 					val /= 4;
-				if (val >= hz)
-					fprintf(fp, " %ums", val/hz);
+				if (val >= hz1)
+					fprintf(fp, " %ums", val/hz1);
 				else
-					fprintf(fp, " %.2fms", (float)val/hz);
+					fprintf(fp, " %.2fms", (float)val/hz1);
 			}
 		}
 	}


Thanks,
Satoru SATOH
