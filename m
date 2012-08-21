From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IP fragmentation broken in 3.6-rc ?
Date: Tue, 21 Aug 2012 16:42:11 +0200
Message-ID: <1345560131.5158.500.camel@edumazet-glaptop>
References: <CAF6-1L6DTXPGi4kbcPqbOXrrafMmZ6K1QdcAa=PxJBzZWkvojg@mail.gmail.com>
	 <1345555336.5158.493.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sylvain Munaut <s.munaut@whatever-company.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:64525 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755136Ab2HUOmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 10:42:19 -0400
Received: by bkwj10 with SMTP id j10so2214443bkw.19
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 07:42:18 -0700 (PDT)
In-Reply-To: <1345555336.5158.493.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-21 at 15:22 +0200, Eric Dumazet wrote:
> On Tue, 2012-08-21 at 15:05 +0200, Sylvain Munaut wrote:
> > Hi,
> > 
> > I'm starting to wonder if it's not related to
> > 46517008e1168dc926cf2c47d529efc07eca85c0 "ipv4: Kill
> > ip_rt_frag_needed()."
> > 
> > Cheers,
> > 
> >     Sylvain
> 
> Hmm, most probably problem came with commit
> ceb3320610d6f15ff20dd4c042b36473d77de76f
> (ipv4: Kill routes during PMTU/redirect updates.)
> 
> 

Following patch should help :

diff --git a/include/net/dst.h b/include/net/dst.h
index 621e351..a04aa37 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -435,7 +435,7 @@ static inline void dst_set_expires(struct dst_entry *dst, int timeout)
 	if (expires == 0)
 		expires = 1;
 
-	if (dst->expires == 0 || time_before(expires, dst->expires))
+	if (dst->expires == 0 || time_after(expires, dst->expires))
 		dst->expires = expires;
 }
 
