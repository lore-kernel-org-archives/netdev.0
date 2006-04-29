From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [RFC] Geographical/regulatory information for ieee80211
Date: Fri, 28 Apr 2006 17:31:35 -0700
Message-ID: <20060429003135.GP31601@instant802.com>
References: <443EF3E9.7050303@lwfinger.net> <20060415174734.GA10595@infradead.org> <4443D694.8090809@hp.com> <44501647.8070308@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>,
	Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-38.dex002.intermedia.net ([64.78.21.123]:17955 "EHLO
	dhost002-38.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751044AbWD2Abn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 20:31:43 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <44501647.8070308@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 26, 2006 at 07:54:31PM -0500, Larry Finger wrote:

> I don't think it would make that much difference as the user could easily 
> lie about their locality and get any set of parameters that they wanted. 

Well, not any set.. One of the configured countries, yes, but that is
not same as setting arbitrary TX power limit and allowed channel sets..
Anyway, users should be allowed to move from one country to another and
still being able to use their wlan card (within the limits of the
current location).

> I am leaning toward putting the geographical information into a userland 
> daemon. That way we won't have to patch the kernel every time a country 
> modifies its regulations. In addition, the kernel will be smaller. The 
> downside is that the daemon will have to be updated and supplied in some 
> convenient form, perhaps as part of a wireless tools package.

I'm strongly in favor of doing this in user space, too. In order to
provide some control on what end users do with this, I would consider
including a signature on a data file and have the user space tool verify
that signature before accepting the data. This signature need not be
anything extra secure, i.e., it could just be a keyed checksum of the
file using a well-known key. The main point here is that it shows some
attempt on limiting end users from setting random values to regulatory
limits. Of course, if someone really wants to change these values, they
could do so since the source code for the tool would be available and so
would the key used for signing the file in the first place.

I don't know how secure a system would be needed to pass requirements
that FCC and similar organizations place on wireless devices. I would
like to handle this with fully open source tools and having some kind of
simple signature on the data file would be good starting point. It is up
to vendors then to decide whether they are fine with such a mechanism or
whether some additional tool (like the Intel plan on using a closed
source user space tool) would be needed on top of this.

-- 
Jouni Malinen                                            PGP id EFC895FA
