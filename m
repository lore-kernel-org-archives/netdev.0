From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: How exactly does CHECKSUM_COMPLETE works?
Date: Tue, 30 Sep 2014 12:37:12 -0700
Message-ID: <1412105832.30721.95.camel@edumazet-glaptop2.roam.corp.google.com>
References: <B5657A6538887040AD3A81F1008BEC63B41317@avmb3.qlogic.org>
	 <CA+mtBx_17aJuK=xjnDukGJOfw-twHg=rF5rDacg6pga6ZTTRcw@mail.gmail.com>
	 <B5657A6538887040AD3A81F1008BEC63B4152D@avmb3.qlogic.org>
	 <1412104977.30721.94.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Tom Herbert (Partner - google)" <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:44876 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858AbaI3ThO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 15:37:14 -0400
Received: by mail-pa0-f54.google.com with SMTP id ey11so8556061pad.41
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 12:37:14 -0700 (PDT)
In-Reply-To: <1412104977.30721.94.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-30 at 12:22 -0700, Eric Dumazet wrote:
> On Tue, 2014-09-30 at 19:05 +0000, Yuval Mintz wrote:
> 
> > Can you pinpoint me to what exactly in the code corrects NAPI_GRO_CB(skb)->csum
> > by negating the ipv4 part in the ones' complete checksum?
> > 
> > E.g., for ipv6 [in ipv6_gro_receive()] I can see that skb_gro_postpull_rcsum() is
> > called after pulling the ipv6 header [and before proceeding to the next protocol],
> > but I can't seem to find anything similar to this for ipv4 [in inet_gro_receive()].
> > 
> 
> 
> IPv4 header is supposed to have a 0 checksum ;)
> 

Or if you prefer :

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 28e589c5f32d..92db7a69f2b9 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1369,6 +1369,9 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 	 * immediately following this IP hdr.
 	 */
 
+	/* Note : No need to call skb_gro_postpull_rcsum() here,
+	 * as we already checked checksum over ipv4 header was 0
+	 */
 	skb_gro_pull(skb, sizeof(*iph));
 	skb_set_transport_header(skb, skb_gro_offset(skb));
 
