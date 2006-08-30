From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 5/7] d80211: indicate if unassociate/radio off status
Date: Wed, 30 Aug 2006 09:41:43 -0400
Message-ID: <1156945303.2725.7.camel@localhost.localdomain>
References: <44F356DF.9000000@linux.intel.com>
	 <44F4BF9E.4040309@linux.intel.com>
	 <200608291550.30203.flamingice@sourmilk.net>
	 <200608291601.56901.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mohamed Abbas <mabbas@linux.intel.com>,
	Jouni Malinen <jkm@devicescape.com>, netdev@vger.kernel.org,
	jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51377 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751044AbWH3NkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 09:40:16 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200608291601.56901.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-29 at 16:01 -0700, Michael Wu wrote:
> On Tuesday 29 August 2006 15:50, Michael Wu wrote:
> > On Tuesday 29 August 2006 15:28, Mohamed Abbas wrote:
> > >  SIOCGIWAP will always report the bssid no
> > > matter what the status of our link.
> >
> > That is not the case at the moment. Were you planning to change that?
> >
> Opps, it looks like it is the case. Ignore that.
> 
> Perhaps we should make SIOCGIWAP always reflect the AP we're currently 
> associated to, and 00:00:00:00:00:00 if there is none.
> 
> -Michael Wu

Um, that's how it's supposed to work, and that's how it's always worked.
If you're associated with an access point, its BSSID is returned from
SIOCGIWAP.  If you are not associated, 00:00:00:00:00:00 is returned.
Please don't break that.  The driver should also send the appropriate
netlink IWAP events when it gets disconnected or when a successful
connection occurs using wireless_send_event().

If a valid BSSID is returned from an SIOCGIWAP, it's assumed that that
access point will allow your traffic to pass, i.e. all required
association and authentication has successfully completed.

SIOCGIWAP behavior does _not_ necessarily reflect what BSSID is set with
SIOCSIWAP.

Dan


