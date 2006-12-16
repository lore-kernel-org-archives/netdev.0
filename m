From: Sam Leffler <sam@errno.com>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver
Date: Fri, 15 Dec 2006 20:20:06 -0800
Message-ID: <458373F6.4030105@errno.com>
References: <20061215225123.GA3231@dmt> <200612152152.25419.flamingice@sourmilk.net> <20061216030322.GV31900@che.ojctech.com> <45836E3D.1090905@errno.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michael Wu <flamingice@sourmilk.net>,
	Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	Dan Williams <dcbw@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"John W. Linville" <linville@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebb.errno.com ([69.12.149.25]:2878 "EHLO ebb.errno.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030233AbWLPEUJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 23:20:09 -0500
To: David Young <dyoung@pobox.com>
In-Reply-To: <45836E3D.1090905@errno.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sam Leffler wrote:
> David Young wrote:
>> On Fri, Dec 15, 2006 at 09:52:20PM -0500, Michael Wu wrote:
>>> On Friday 15 December 2006 17:51, Marcelo Tosatti wrote:
>>>> --- a/include/net/ieee80211_radiotap.h
>>>> +++ b/include/net/ieee80211_radiotap.h
>>>> @@ -168,6 +168,23 @@ struct ieee80211_radiotap_header {
>>>>  *      Unitless indication of the Rx/Tx antenna for this packet.
>>>>  *      The first antenna is antenna 0.
>>>>  *
>>>> + * IEEE80211_RADIOTAP_RX_FLAGS          u_int16_t       bitmap
>>>> + *
>>>> + *     Properties of received frames. See flags defined below.
>>>> + *
>>>> + * IEEE80211_RADIOTAP_TX_FLAGS          u_int16_t       bitmap
>>>> + *
>>>> + *     Properties of transmitted frames. See flags defined below.
>>>> + *
>>>> + * IEEE80211_RADIOTAP_RTS_RETRIES       u_int8_t        data
>>>> + *
>>>> + *     Number of rts retries a transmitted frame used.
>>>> + *
>>>> + * IEEE80211_RADIOTAP_DATA_RETRIES      u_int8_t        data
>>>> + *
>>>> + *     Number of unicast retries a transmitted frame used.
>>>> + *
>>>> + *
>>>>  * IEEE80211_RADIOTAP_FCS              u32       data
>>>>  *
>>>>  *     FCS from frame in network byte order.
>>>> @@ -187,7 +204,11 @@ enum ieee80211_radiotap_type {
>>>>        IEEE80211_RADIOTAP_ANTENNA = 11,
>>>>        IEEE80211_RADIOTAP_DB_ANTSIGNAL = 12,
>>>>        IEEE80211_RADIOTAP_DB_ANTNOISE = 13,
>>>> -       IEEE80211_RADIOTAP_EXT = 31,
>>>> +       IEEE80211_RADIOTAP_RX_FLAGS = 14,
>>>> +       IEEE80211_RADIOTAP_TX_FLAGS = 15,
>>>> +       IEEE80211_RADIOTAP_RTS_RETRIES = 16,
>>>> +       IEEE80211_RADIOTAP_DATA_RETRIES = 17,
>>>> +       IEEE80211_RADIOTAP_EXT = 31
>>>> };
>>>>
>>>> /* Channel flags. */
>>> Did you send this part to netbsd also? We really don't want to fork 
>>> radiotap. ;) Also, this should be in a separate patch, but I'm guessing it's 
>>> all rolled together for convenience.
>> No, especially since NetBSD is where I keep the authoritative definitions.
>>
>> How have you defined RX_FLAGS and TX_FLAGS?
>>
>> BTW, IEEE80211_RADIOTAP_FCS (above) never made it into radiotap.  No bit
>> is reserved.
> 
> Tell that to everyone that implements it.
> 

My mistake.  David pointed out correctly that the mechanism for adding
the FCS out-of-line (IEEE80211_RADIOTAP_FCS) was not used.  Instead
there is a flag bit that tells whether or not FCS is present (inline) in
the data.  This flag bit is what I was thinking of--it's honored by
ethereal (aka wireshark), kismet, tcpdump, etc.

	Sam
