From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 02/39] wimax: declarations for the in-kernel WiMAX API
Date: Thu, 04 Dec 2008 10:04:30 +0100
Message-ID: <1228381470.3197.22.camel@Friederike-PC.hoffi>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <68881c1af06f352dc457485c208662a8db62f3fe.1227691434.git.inaky@linux.intel.com>
	 <1227778323.3809.19.camel@johannes.berg>
	 <200812021807.31959.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:43015 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944AbYLDJFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 04:05:14 -0500
In-Reply-To: <200812021807.31959.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-12-02 at 18:07 -0800, Inaky Perez-Gonzalez wrote:
> On Thursday 27 November 2008, Johannes Berg wrote:
> > Why bother versioning the API? Since this is generic netlink, and things
> > are looked up by the family name, a completely new version would just
> > use a new family name and be done with it, old userspace won't even
> > _find_ that new "version" of the API.
> 
> That'd be a way to do majors -- hadn't thought about it.
> 
> But then, it forces a way to create "a way to grok versions" in the
> family name, which is moving the problem from one place to the other.
> 
> Because parsing in the family means having to set a protocol and
> parsing ASCII, I'd say it's easier to use the family's version field,
> as it is available.

I wasn't actually advocating parsing the family name, but thinking that
if you were to actually do a major revision then you'd be rewriting all
the userland code anyway and could just hardcode a new family name
there.

> > The "minor version" seems also
> > useless, either you can do the change in a backward compatible way or
> > you cannot and need to provide compat code.
> 
> No it is not -- you are missing the case of adding an API
> call/signal. Addition doesn't break backwards compatibility, yet a
> user that requires the addition has to double check it is
> available.

No! API additions can always be discovered through the genl controller,
it supports listing which operations are available. Check out the genl
command from iproute2.

johannes

