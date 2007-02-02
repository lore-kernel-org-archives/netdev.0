From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: [PATCH] ieee80211: Fix sparse warning
Date: Fri, 02 Feb 2007 15:38:09 -0600
Message-ID: <45C3AF41.1030908@lwfinger.net>
References: <45c1394b.An8WeE68tSLsbJYy%Larry.Finger@lwfinger.net> <20070202203201.GB9382@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:63129 "EHLO
	mtiwmhc13.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1946119AbXBBViQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Feb 2007 16:38:16 -0500
In-Reply-To: <20070202203201.GB9382@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> On Wed, Jan 31, 2007 at 06:50:19PM -0600, Larry Finger wrote:
>> Sparse issues the warning "warning: symbol 'crypt' shadows an earlier one"
>> in net/ieee80211/ieee80211_tx.c.
>>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>> ---
>>
>> Index: wireless-2.6/net/ieee80211/ieee80211_tx.c
>> ===================================================================
>> --- wireless-2.6.orig/net/ieee80211/ieee80211_tx.c
>> +++ wireless-2.6/net/ieee80211/ieee80211_tx.c
>> @@ -502,8 +502,6 @@ int ieee80211_xmit(struct sk_buff *skb, 
>>  		if (host_encrypt)
>>  			ieee80211_encrypt_fragment(ieee, skb_frag, hdr_len);
>>  		else if (host_build_iv) {
>> -			struct ieee80211_crypt_data *crypt;
>> -
>>  			crypt = ieee->crypt[ieee->tx_keyidx];
>>  			atomic_inc(&crypt->refcnt);
>>  			if (crypt->ops->build_iv)
> 
> Couldn't you remove the "crypt = ieee->crypt[ieee->tx_keyidx];"
> as well?

Yes it can. I'll send a revised patch along shortly.

Larry
