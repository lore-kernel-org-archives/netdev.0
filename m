From: Dan Williams <dcbw@redhat.com>
Subject: Re: [patch net-next V2] bond: have random dev address by default
 instead of zeroes
Date: Tue, 29 Jan 2013 11:54:22 -0600
Message-ID: <1359482062.1635.17.camel@dcbw.foobar.com>
References: <542237717.4200599.1359136587903.JavaMail.root@redhat.com>
	 <22106.1359138692@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pavel Simerda <psimerda@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net,
	stephen@networkplumber.org, Jiri Pirko <jiri@resnulli.us>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16866 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754398Ab3A2R4L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 12:56:11 -0500
In-Reply-To: <22106.1359138692@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-25 at 10:31 -0800, Jay Vosburgh wrote:
> Pavel Simerda <psimerda@redhat.com> wrote:
> 
> >----- Original Message -----
> >> From: "Jay Vosburgh" <fubar@us.ibm.com>
> >> but I don't think it should be changed.
> >
> >Just a short question. Is there any reason for bonding interfaces to
> >behave differently from bridging interfaces in this respect?
> 
> 	To clarify, what I don't think should change is that a manually
> set MAC on the bonding master should override the automatic copy of the
> first slave's MAC to the bonding master.  The fail_over_mac active and
> follow settings are an exception to this, but those are special cases
> for unusual network hardware.
> 
> 	As for the random MAC vs. zero MAC, I've always thought that the
> all zero MAC was a clear indicator that the device (the bonding master
> in this case) was not in a usable state (in the sense that it could not
> send or receive actual traffic).  It's not a really big deal, though, so
> if the trend these days is for everything to have a MAC all the time,
> that's fine, as long as doing so doesn't break anything.

Isn't that exactly what carrier means?  If the carrier bit is off,
nothing should expect that traffic can pass.  The bond will only set its
carrier ON if at least one slave exists and at least one slave has a
carrier that's ON.  We have overrides for buggy driver carrier checking
already.  Zero-MAC is somewhat redundant here as a mechanism for
detecting that the bond is usable or not.

Dan

> 	I think the patch under discussion should be fine with the
> addition of the last notifier call previously discussed.  Some
> documentation updates would be nice, too.
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> 
