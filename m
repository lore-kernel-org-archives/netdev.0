From: charley <charley.chu@yahoo.com>
Subject: Re: Kernel Oops in =?utf-8?b?X19pbmV0X3R3c2tfa2lsbCgp?=
Date: Mon, 3 Aug 2015 02:19:56 +0000 (UTC)
Message-ID: <loom.20150803T035445-326@post.gmane.org>
References: <545A49B4.7090107@iogearbox.net> <CAHA+R7PAdVS=TBd8ZDAW3wdadjNEVjiyemrs54wNp8fdtCMvZQ@mail.gmail.com> <FB8A4655DFD2B34DB16AE06DDDD6C0E231A71CE3@SJEXCHMB12.corp.ad.broadcom.com> <20141105.143929.861274469992898400.davem@davemloft.net> <FB8A4655DFD2B34DB16AE06DDDD6C0E231A72A4B@SJEXCHMB12.corp.ad.broadcom.com> <loom.20150710T183514-452@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:33666 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750924AbbHCCZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Aug 2015 22:25:08 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1ZM5R2-0002Ft-Sh
	for netdev@vger.kernel.org; Mon, 03 Aug 2015 04:25:05 +0200
Received: from S0106bc4dfb1c2143.vs.shawcable.net ([96.55.76.170])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 04:25:04 +0200
Received: from charley.chu by S0106bc4dfb1c2143.vs.shawcable.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 04:25:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phani <pgargey <at> yahoo.com> writes:

> 
> 
> > 
> > > The problem has been fixed. It is introduced by a third party patch,
> > > which decreases the refcnt of timewait socket.
> >
> 
> What is the fix?
> pl share the gerrit.
> 
> 

Here you go.

https://android.googlesource.com/kernel/common/+/android-
3.14/net/netfilter/xt_qtaguid.c


diff --git a/net/netfilter/xt_qtaguid.c b/net/netfilter/xt_qtaguid.c
--- a/net/netfilter/xt_qtaguid.c
+++ b/net/netfilter/xt_qtaguid.c
@@ -1605,7 +1605,8 @@ static struct sock 
*qtaguid_find_sk(const struct sk_buff *skb,
 		 * "struct inet_timewait_sock" which is missing fields.
		 */
		if (sk->sk_state  == TCP_TIME_WAIT) {
-			sock_gen_put(sk);
+                      if (sk != skb-sk)
+			    sock_gen_put(sk);
			sk = NULL;
		}
	}
