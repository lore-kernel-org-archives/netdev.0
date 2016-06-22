From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v2 7/7] ip/tcp_metrics: Simplify process_msg a bit
Date: Wed, 22 Jun 2016 15:08:57 +0200
Message-ID: <20160622130857.GC15980@orbyte.nwl.cc>
References: <1466525921-15738-1-git-send-email-phil@nwl.cc>
 <1466525921-15738-8-git-send-email-phil@nwl.cc>
 <87k2hhmp8q.fsf@frog.home>
 <063D6719AE5E284EB5DD2968C1650D6D5F4E2559@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Jakub Sitnicki' <jkbs@redhat.com>,
	Stephen Hemminger <shemming@brocade.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53288 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751214AbcFVNI7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 09:08:59 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F4E2559@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, Jun 22, 2016 at 01:00:08PM +0000, David Laight wrote:
> From: Jakub Sitnicki
> > Sent: 22 June 2016 12:34
> ...
> > > -	a = attrs[TCP_METRICS_ATTR_ADDR_IPV4];
> > > -	if (a) {
> > > +	if ((a = attrs[TCP_METRICS_ATTR_ADDR_IPV4])) {
> > 
> > Copy the pointer inside the branch?
> > 
> > Same gain on indentation while keeping checkpatch happy.
> 
> Or as below (hacked from the mails):
> 
> 	a = attrs[TCP_METRICS_ATTR_ADDR_IPV4];
> 	if (a) {
>  		if (f.daddr.family && f.daddr.family != AF_INET)
>  			return 0;
>  		memcpy(&daddr.data, RTA_DATA(a), 4);
>  		daddr.bytelen = 4;
>  		family = AF_INET;
>  		atype = TCP_METRICS_ATTR_ADDR_IPV4;
>  		dlen = RTA_PAYLOAD(a);
> 	} else {
> 		a = attrs[TCP_METRICS_ATTR_ADDR_IPV6];
> 		if (!a)
> 			return 0;
> 		memcpy(&daddr.data, RTA_DATA(a), 16);
> 		daddr.bytelen = 16;
> 		family = AF_INET6;
> 		atype = TCP_METRICS_ATTR_ADDR_IPV6;
> 		dlen = RTA_PAYLOAD(a);
> 	}

Yes, this should work as well and require less code changes overall.
Though I think it's less readable:

| if (a) {
| 	do a;
| else {
| 	if (!b)
| 		return;
| 	do b;
| }

vs.

| if (a) {
| 	do a;
| } else if (b) {
| 	do b;
| } else {
| 	return;
| }

Don't you think?

Thanks, Phil
