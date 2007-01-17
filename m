From: Brandon Craig Rhodes <brandon@rhodesmill.org>
Subject: Re: TKIP encryption should allocate enough tailroom
Date: Wed, 17 Jan 2007 11:46:35 -0500
Message-ID: <87mz4h61p0.fsf@ten22.rhodesmill.org>
References: <87bqky759v.fsf@ten22.rhodesmill.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-23-211-138.clients.speedfactory.net ([66.23.211.138]:58207
	"EHLO ten22.rhodesmill.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932578AbXAQQqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jan 2007 11:46:36 -0500
To: netdev@vger.kernel.org
In-Reply-To: <87bqky759v.fsf@ten22.rhodesmill.org> (Brandon Craig Rhodes's
	message of "Tue, 16 Jan 2007 21:31:40 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I wrote:

> After frustrating days of hung TCP connections, I have determined that
> the encryption routines in net/iee80211/ieee80211_crypt_tkip.c should
> be more aggressive in providing themselves with enough packet tailroom
> to perform their encryption.

Having further reviewed my code, I have changed my mind; the
ieee80211_crypt_tkip routines are not designed to be responsible for
creating enough headroom and tailroom.  The "hostap" driver should be
doing this.  In fact, I now see that the "hostap" driver actually
attempts to create enough headroom and tailroom, but computes them
incorrectly.

I will, per the MAINTAINERS file, head back to the hostap mailing list
with a patch for hostap_80211_tx.c - this time, CC'ing the official
maintainer, as I ought; thank you, Michael Wu, for making me aware of
that bit of courtesy.

-- 
Brandon Craig Rhodes   brandon@rhodesmill.org   http://rhodesmill.org/brandon
