From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] improved statistics for bcm43xx-softmac
Date: Thu, 29 Jun 2006 10:31:34 -0500
Message-ID: <44A3F256.2090601@lwfinger.net>
References: <44A3524C.40704@lwfinger.net> <200606291712.21973.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:40692 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750792AbWF2Pbj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 11:31:39 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200606291712.21973.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Thursday 29 June 2006 06:08, Larry Finger wrote:
>> 	/* fill in the real statistics when iface associated */
>> -	wstats->qual.qual = 100;     // TODO: get the real signal quality
>> -	wstats->qual.level = 3 - bcm->stats.link_quality;
>> +	list_for_each_entry(network, &mac->ieee->network_list, list) {
>> +		if (!memcmp(mac->associnfo.bssid, network->bssid, ETH_ALEN)) {
>> +			if (!tmp_level)		/* get initial value */
>> +				tmp_level = network->stats.rssi;
>> +			else			/* smooth results */
>> +				tmp_level = (7 * tmp_level + network->stats.rssi)/8;
>> +			break;
>> +		}
>> +	}
> 
> You need to lock the ieee80211 lock here. Otherwise it might race and crash,
> if some workqueue modifies the list inbetween.

Thanks for the comment. Is there an easier way to get to network->stats?

Larry
