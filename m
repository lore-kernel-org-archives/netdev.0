From: Dan Williams <dcbw@redhat.com>
Subject: Re: SIOCGIWSCAN wireless event behaviour
Date: Thu, 20 Apr 2006 10:37:32 -0400
Message-ID: <1145543852.2654.11.camel@localhost.localdomain>
References: <4447979F.4050603@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, softmac-dev@sipsolutions.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54158 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1750797AbWDTOlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2006 10:41:18 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <4447979F.4050603@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-04-20 at 15:15 +0100, Daniel Drake wrote:
> Hi Jean,
> 
> A query regarding wireless events: under which circumstances should a 
> driver/stack send a SIOCGIWSCAN event to userspace?
> 
> Should it be sent whenever a driver has new scan results available, or 
> only when the user requested a scan a short time beforehand (via 
> SIOCSIWSCAN)?

Similar situation:  when wpa_supplicant requests a scan, the driver
scans and pushes the GIWSCAN at completion.  _Every_ process (like
NetworkManager) listening for netlink WE messages gets the GIWSCAN event
even though only wpa_supplicant requested the original scan.

So what I'm saying is that applications that process GIWSCAN netlink
messages today should _already_ be able to handle random GIWSCAN events
at any time even when they have not explicitly requested a scan with
SIWSCAN.  The events are broadcast and the driver shouldn't really care
which user app initiated any particular request.  Multiple apps can
theoretically request scans at any time, though this isn't so good in
practice.

> I ask this because softmac is sending the SIOCGIWSCAN event even when 
> the user did not explicitly ask for it.

Given the above, I think this behavior is fine and even desirable.

> I think the 'extra' SIOCGIWSCAN event may be confusing wpa_supplicant 
> (but have not confirmed that yet).

If this is the case, wpa_supplicant should not be getting confused by
GIWSCAN events happening at random times, and should be fixed.  However,
in my experience with 0.4.8, this isn't a problem and wpa_supplicant
handles random scan events correctly.  Not sure about the 0.5.x branch
though.

Dan


