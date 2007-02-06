From: David Young <dyoung@pobox.com>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver
Date: Tue, 6 Feb 2007 17:21:57 -0600
Message-ID: <20070206232157.GG31900@che.ojctech.com>
References: <20061215225123.GA3231@dmt> <200612152152.25419.flamingice@sourmilk.net> <20061216030322.GV31900@che.ojctech.com> <20061218195723.GB7260@dmt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Wu <flamingice@sourmilk.net>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	Dan Williams <dcbw@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"John W. Linville" <linville@redhat.com>, sam@errno.com
To: Marcelo Tosatti <marcelo@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from che.ojctech.com ([64.198.255.2]:58839 "EHLO che.ojctech.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030287AbXBGAQZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 19:16:25 -0500
Content-Disposition: inline
In-Reply-To: <20061218195723.GB7260@dmt>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 18, 2006 at 05:57:23PM -0200, Marcelo Tosatti wrote:
> 
> > > > /* Channel flags. */
> > > Did you send this part to netbsd also? We really don't want to fork 
> > > radiotap. ;) Also, this should be in a separate patch, but I'm guessing it's 
> > > all rolled together for convenience.
> > 
> > No, especially since NetBSD is where I keep the authoritative definitions.
> > 
> > How have you defined RX_FLAGS and TX_FLAGS?
> 
> Oh yes, missed that part of the patch. Sorry.

Sorry for the delayed response, it's been a busy couple of months.

There is now a mailing list for discussing radiotap.  Subscribe at
<http://mail.ojctech.com/mailman/listinfo/radiotap>.  I ask that you
send proposals for new fields to the mailing list for discussion.  I am
interested to see proposals for 802.11n.  A couple of people have already
promised me proposals, but they never sent them.

A couple words about the fields you mention:

> --- a/include/net/ieee80211_radiotap.h
> +++ b/include/net/ieee80211_radiotap.h
> @@ -168,6 +168,23 @@ struct ieee80211_radiotap_header {
>   *      Unitless indication of the Rx/Tx antenna for this packet.
>   *      The first antenna is antenna 0.
>   *
> + * IEEE80211_RADIOTAP_RX_FLAGS          u_int16_t       bitmap
> + *
> + *     Properties of received frames. See flags defined below.
> + *
> + * IEEE80211_RADIOTAP_TX_FLAGS          u_int16_t       bitmap
> + *
> + *     Properties of transmitted frames. See flags defined below.
> + *
> + * IEEE80211_RADIOTAP_RTS_RETRIES       u_int8_t        data
> + *
> + *     Number of rts retries a transmitted frame used.
> + *
> + * IEEE80211_RADIOTAP_DATA_RETRIES      u_int8_t        data
> + *
> + *     Number of unicast retries a transmitted frame used.
> + *
> + *
>   * IEEE80211_RADIOTAP_FCS           	u32       data
>   *
>   *	FCS from frame in network byte order.
> @@ -187,7 +204,11 @@ enum ieee80211_radiotap_type {
>  	IEEE80211_RADIOTAP_ANTENNA = 11,
>  	IEEE80211_RADIOTAP_DB_ANTSIGNAL = 12,
>  	IEEE80211_RADIOTAP_DB_ANTNOISE = 13,
> -	IEEE80211_RADIOTAP_EXT = 31,
> +	IEEE80211_RADIOTAP_RX_FLAGS = 14,
> +	IEEE80211_RADIOTAP_TX_FLAGS = 15,
> +	IEEE80211_RADIOTAP_RTS_RETRIES = 16,
> +	IEEE80211_RADIOTAP_DATA_RETRIES = 17,
> +	IEEE80211_RADIOTAP_EXT = 31
>  };

I remember discussing these fields, but they were for somebody's
experimental use.  All of the fields are acceptable to me, but this flag
is questionable; it duplicates the function of another flag:

> +#define IEEE80211_RADIOTAP_F_RX_BADFCS	0x0001	/* frame failed crc check */

If it is important to people that I add this flag, let's discuss on the
mailing list.

Dave

-- 
David Young             OJC Technologies
dyoung@ojctech.com      Urbana, IL * (217) 278-3933
