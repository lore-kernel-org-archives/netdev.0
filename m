From: Erik Stromdahl <erik.stromdahl@gmail.com>
Subject: Re: [PATCH] mac80211_hwsim: Added vendor echo command
Date: Sat, 25 Jun 2016 18:08:01 +0200
Message-ID: <576EAC61.1050900@gmail.com>
References: <1466756034-5485-1-git-send-email-erik.stromdahl@gmail.com>
 <20160624204759.GA15514@w1.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, johannes.berg@intel.com,
	kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Jouni Malinen <j@w1.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34532 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbcFYQIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 12:08:06 -0400
In-Reply-To: <20160624204759.GA15514@w1.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mac80211_hwsim driver is currently defining the QCA vendor ID 
0x001374 for some reason.

Also, all current vendor commands are using the "QCA_" prefix, hence the 
reason why I decided to add the new vendor command with the "QCA_" 
prefix as well.

Anyway, I understand that you don't want the hwsim driver bloated with 
definitions that does not belong there.

Is there any reason why hwsim uses the QCA vendor id?
Perhaps it would be best if the hwsim driver would define its own vendor id?

On 06/24/2016 10:47 PM, Jouni Malinen wrote:
> On Fri, Jun 24, 2016 at 10:13:54AM +0200, Erik Stromdahl wrote:
>> The purpose of the echo command is to provide a test
>> facility for user space programs.
>
>> diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
>> @@ -332,14 +332,16 @@ static const struct ieee80211_rate hwsim_rates[] = {
>>   #define QCA_NL80211_SUBCMD_TEST 1
>> +#define QCA_NL80211_SUBCMD_ECHO 2
>
> NAK. That QCA vendor specific value has not been assigned nor have I
> even seen a request to assign such a value.
>
>>   enum qca_nl80211_vendor_subcmds {
>>   	QCA_WLAN_VENDOR_ATTR_TEST = 8,
>> -	QCA_WLAN_VENDOR_ATTR_MAX = QCA_WLAN_VENDOR_ATTR_TEST
>> +	QCA_WLAN_VENDOR_ATTR_ECHO,
>
> And this vendor attribute value has already been assigned for another
> purpose.
>
> It is no acceptable to pick arbitrary values of identifiers without
> proper request to the owner of the OUI that is used to assign the
> values.
>
> As far as the QCA vendor specific identifiers are concerned, their
> assignment process is described here:
> http://w1.fi/cgit/hostap/plain/src/common/qca-vendor.h
>
> Please do not submit kernel changes that use any unassigned vendor
> identifier or even worse, a value that have already been assigned for a
> completely different purpose.
>
>
