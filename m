From: "Tomas Winkler" <tomasw@gmail.com>
Subject: Re: mac80211 truesize bugs
Date: Wed, 14 May 2008 00:12:09 +0300
Message-ID: <1ba2fa240805131412i3bd1756bhb11d31742b326b2f@mail.gmail.com>
References: <20080502.163334.148944203.davem@davemloft.net>
	 <1209807477.3987.9.camel@johannes.berg>
	 <1209824720.1475.6.camel@johannes.berg>
	 <20080512.201751.114868351.davem@davemloft.net>
	 <20080513203906.GB20269@tuxdriver.com>
	 <1210712356.4279.22.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au,
	mb@bu3sch.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: "Johannes Berg" <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:46072 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759293AbYEMVML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 17:12:11 -0400
Received: by wa-out-1112.google.com with SMTP id j37so4348644waf.23
        for <netdev@vger.kernel.org>; Tue, 13 May 2008 14:12:10 -0700 (PDT)
In-Reply-To: <1210712356.4279.22.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 13, 2008 at 11:59 PM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Tue, 2008-05-13 at 16:39 -0400, John W. Linville wrote:
>  > On Mon, May 12, 2008 at 08:17:51PM -0700, David Miller wrote:
>  >
>  > > Based upon them I will adjust LL_MAX_HEADER as follows:
>  >
>  > > @@ -93,14 +93,16 @@ struct wireless_dev;
>  > >   * used.
>  > >   */
>  > >
>  > > -#if !defined(CONFIG_AX25) && !defined(CONFIG_AX25_MODULE) && !defined(CONFIG_TR)
>  > > -#define LL_MAX_HEADER      32
>  > > +#if defined(CONFIG_WLAN_80211) || defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
>  >
>  > Is WLAN_80211 really the right symbol here?  It applies to more than
>  > just mac80211, and I doubt if full MAC devices need higher values.
>  > It seems like MAC80211 would be the right symbol to add.
>
>  Most fullmac devices also need some space, whether they do things that
>  way or not is a completely different thing, the ieee80211 stack for
>  example copies every packet into a new skb anyway.

It's really depends on when is the 802.3 to 802.11 header translation
made it doesn't matter whether it's fullmac or softmac. I would say
that WLAN is OK.

Tomas
