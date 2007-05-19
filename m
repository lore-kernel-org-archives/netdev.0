From: Eugene Teo <eteo@redhat.com>
Subject: Re: [2.6 patch] net/llc/llc_conn.c: fix possible NULL dereference
Date: Sat, 19 May 2007 13:49:11 +0800
Message-ID: <464E8FD7.9030203@redhat.com>
References: <464E8763.3010609@redhat.com> <20070518223005.91236c38.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020207060804050902060402"
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Eugene Teo <eteo@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59044 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755805AbXESFvS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 May 2007 01:51:18 -0400
In-Reply-To: <20070518223005.91236c38.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020207060804050902060402
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Randy Dunlap wrote:
> On Sat, 19 May 2007 13:13:07 +0800 Eugene Teo wrote:
> 
>> skb_peek() might return an empty list. skb should be checked before calling
>> llc_pdu_sn_hdr() with it.
>>
>> Spotted by the Coverity checker.
>>
>> Signed-off-by: Eugene Teo <eteo@redhat.com>
[...]
> 
> Oh, and your patch has spaces instead of tabs.  It's a hassle to
> get thunderbird to send a patch that preserves tabs.  See if this:
>    http://mbligh.org/linuxdocs/Email/Clients/Thunderbird
> helps you any.

Here's a resend:

skb_peek() might return an empty list. skb should be checked before calling
llc_pdu_sn_hdr() with it.

Spotted by the Coverity checker.

Signed-off-by: Eugene Teo <eteo@redhat.com>

--------------020207060804050902060402
Content-Type: text/x-patch;
 name="2.6-llc_conn.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="2.6-llc_conn.patch"

diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index 3b8cfbe..6d3a07e 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -324,6 +324,8 @@ int llc_conn_remove_acked_pdus(struct sock *sk, u8 nr, u16 *how_many_unacked)
 	if (!q_len)
 		goto out;
 	skb = skb_peek(&llc->pdu_unack_q);
+	if (!skb)
+		goto out;
 	pdu = llc_pdu_sn_hdr(skb);
 
 	/* finding position of last acked pdu in queue */

--------------020207060804050902060402--
