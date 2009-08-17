From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] bridge: prevent hairpin and STP problems?
Date: Mon, 17 Aug 2009 15:37:25 -0700
Message-ID: <20090817153725.47c04fca@nehalam>
References: <0199E0D51A61344794750DC57738F58E6D6B0C70D9@GVW1118EXC.americas.hpqcorp.net>
	<20090813.162716.207478915.davem@davemloft.net>
	<20090814144133.34ac9d94@nehalam>
	<0199E0D51A61344794750DC57738F58E6D6B0C79D7@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ptcongdon@ucdavis.edu" <ptcongdon@ucdavis.edu>,
	"evb@yahoogroups.com" <evb@yahoogroups.com>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"Dickson, Mike (ISS Software)" <mike.dickson@hp.com>,
	"adobriyan@gmail.com" <adobriyan@gmail.com>,
	"bridge@osdl.org" <bridge@linux-foundation.org>
To: "Fischer, Anna" <anna.fischer@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41375 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932521AbZHQWhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 18:37:53 -0400
In-Reply-To: <0199E0D51A61344794750DC57738F58E6D6B0C79D7@GVW1118EXC.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Aug 2009 21:16:04 +0000
"Fischer, Anna" <anna.fischer@hp.com> wrote:

> > Subject: [RFC] bridge: prevent hairpin and STP problems?
> > 
> > Do we need to add this to block Spanning Tree from being enabled
> > with hairpin mode? I am not sure what the exact usage of hairpin
> > mode and if it is possible to create loops and get STP confusion.
> > 
> > For comment only, do not apply as is.
> 
> Your patch disables STP on the whole bridge if one or more ports
> are set to hairpin mode.
> 
> However, I don't really see that this is necessary. 
> 
> A hairpin mode port should not reflect BPDUs, because otherwise the
> connected port would think it has detected a loop. The hairpin mode
> port should still be able to generate BPDUs though, and in any case
> the bridge should still be able to run STP.
> 
> The hairpin patch we submitted reflects packets on the forwarding /
> data path whereas BPDUs are processed with a separate hook, so we
> should not be reflecting BPDUs back out of a hairpin mode port.

So if user is using hairpin properly, the STP would work. In fact
it would be a good thing since it would detect looping configurations.
