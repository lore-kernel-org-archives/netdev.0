From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 1/6] utils: Implement strlcpy() and strlcat()
Date: Mon, 4 Sep 2017 17:00:15 +0200
Message-ID: <20170904150015.GB30364@orbyte.nwl.cc>
References: <20170901165256.21459-1-phil@nwl.cc>
 <20170901165256.21459-2-phil@nwl.cc>
 <063D6719AE5E284EB5DD2968C1650D6DD006D878@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:57987 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753801AbdIDPAQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 4 Sep 2017 11:00:16 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD006D878@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 04, 2017 at 02:49:20PM +0000, David Laight wrote:
> From: Phil Sutter
> > Sent: 01 September 2017 17:53
> > By making use of strncpy(), both implementations are really simple so
> > there is no need to add libbsd as additional dependency.
> > 
> ...
> > +
> > +size_t strlcpy(char *dst, const char *src, size_t size)
> > +{
> > +	if (size) {
> > +		strncpy(dst, src, size - 1);
> > +		dst[size - 1] = '\0';
> > +	}
> > +	return strlen(src);
> > +}
> 
> Except that isn't really strlcpy().
> Better would be:
> 	len = strlen(src) + 1;
> 	if (len <= size)
> 		memcpy(dst, src, len);
> 	else if (size) {
> 		dst[size - 1] = 0;
> 		memcpy(dst, src, size - 1);
> 	}
> 	return len - 1;

Please elaborate: Why isn't my version "really" strlcpy()? Why is your
proposed version better?

Thanks, Phil
