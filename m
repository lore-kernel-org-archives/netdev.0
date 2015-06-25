From: leroy christophe <christophe.leroy@c-s.fr>
Subject: RESEND: Performance loss due to commit  37c3185 ([NET]: Added GSO
 toggle)
Date: Thu, 25 Jun 2015 16:57:30 +0200
Message-ID: <558C16DA.7060100@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-crypto <linux-crypto@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2.236.17.93.rev.sfr.net ([93.17.236.2]:9898 "EHLO
	mailhub1.si.c-s.fr" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751555AbbFYO5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 10:57:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Herbert,

In commit "[NET]: Added GSO toggle" 
37c3185a02d4b85fbe134bf5204535405dd2c957,
you force NETIF_F_HW_CSUM if GSO feature is selected.
By default, SW GSO is active as soon as a network board has NETIF_F_SG 
feature.
This means that function sk_setup_caps() forces NETIF_F_HW_CSUM for any 
board having NETIF_F_SG

For boards having no HW checksum capability, this results in performance 
loss due to data copy being done in skb_do_copy_data_nocache() with 
copy_from_user() then checksum being done later with csum_partial() 
instead of getting both done at the same time using 
csum_and_copy_from_user()

What is the reason for forcing NETIF_F_HW_CSUM   ?

Christophe
