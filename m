From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [iproute PATCH v2 7/7] ip/tcp_metrics: Simplify process_msg a
 bit
Date: Wed, 22 Jun 2016 13:00:08 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4E2559@AcuExch.aculab.com>
References: <1466525921-15738-1-git-send-email-phil@nwl.cc>
 <1466525921-15738-8-git-send-email-phil@nwl.cc> <87k2hhmp8q.fsf@frog.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <shemming@brocade.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	"Nicolas Dichtel" <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Jakub Sitnicki' <jkbs@redhat.com>, Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.187]:59880 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434AbcFVNFE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 09:05:04 -0400
In-Reply-To: <87k2hhmp8q.fsf@frog.home>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Sitnicki
> Sent: 22 June 2016 12:34
...
> > -	a = attrs[TCP_METRICS_ATTR_ADDR_IPV4];
> > -	if (a) {
> > +	if ((a = attrs[TCP_METRICS_ATTR_ADDR_IPV4])) {
> 
> Copy the pointer inside the branch?
> 
> Same gain on indentation while keeping checkpatch happy.

Or as below (hacked from the mails):

	a = attrs[TCP_METRICS_ATTR_ADDR_IPV4];
	if (a) {
 		if (f.daddr.family && f.daddr.family != AF_INET)
 			return 0;
 		memcpy(&daddr.data, RTA_DATA(a), 4);
 		daddr.bytelen = 4;
 		family = AF_INET;
 		atype = TCP_METRICS_ATTR_ADDR_IPV4;
 		dlen = RTA_PAYLOAD(a);
	} else {
		a = attrs[TCP_METRICS_ATTR_ADDR_IPV6];
		if (!a)
			return 0;
		memcpy(&daddr.data, RTA_DATA(a), 16);
		daddr.bytelen = 16;
		family = AF_INET6;
		atype = TCP_METRICS_ATTR_ADDR_IPV6;
		dlen = RTA_PAYLOAD(a);
	}

	David
