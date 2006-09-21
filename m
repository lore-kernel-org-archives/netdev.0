From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 5/7] d80211: indicate if unassociate/radio off status
Date: Thu, 21 Sep 2006 15:03:56 -0400
Message-ID: <1158865436.27546.23.camel@localhost.localdomain>
References: <44F356DF.9000000@linux.intel.com>
	 <20060921190126.4d884c44@logostar.upir.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mabbas <mabbas@linux.intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:63719 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751462AbWIUTCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 15:02:08 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060921190126.4d884c44@logostar.upir.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-09-21 at 19:01 +0200, Jiri Benc wrote:
> On Mon, 28 Aug 2006 13:49:35 -0700, mabbas wrote:
> > This patch indicate unassociated and radio off status
> > in name field
> 
> NAK.
> 
> Fix SIOCGIWAP handler instead.

Right; the _one_ place anyone should ever have to check for unassociated
status is SIOCGIWAP.  That's it.  Lets not put stuff in two different
places.  If it's all 0s, all 4s (stupid prism) or all Fs (i forget who
does that), it's invalid and you're not connected.

About the worst thing we can start doing is having to parse arbitrary
strings to find out driver/card status.  That's the same problem with
"<hidden>" which hope DIES DIES DIES with d80211.  If the AP is hidden,
then it has a _blank_ SSID, not hacked to "<hidden>".

For radio off, that may be a legitimate thing that's not covered in WE
yet.  But isn't that the domain of SIOCGIWPOWER, or is that just used to
set PM modes and not return current status? [1]

Dan

[1] which would seem like an oversight to correct in nl80211

>  Jiri
> 

