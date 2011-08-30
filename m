From: Tom Herbert <therbert@google.com>
Subject: Re: BQL crap and wireless
Date: Mon, 29 Aug 2011 20:34:20 -0700
Message-ID: <CA+mtBx-j_+mrNpntR7CfYOromDnM-ZGzvebpUCjC8Qf14X6u9g@mail.gmail.com>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com>
	<CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com>
	<CAA93jw7c+Nxc6ZbWZWsQ+F78AoPWU=quSRaOUpT0yRcwJOXsGQ@mail.gmail.com>
	<4E5C3B47.1050809@freedesktop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Luis R. Rodriguez" <mcgrof@gmail.com>,
	Dave Taht <dave.taht@gmail.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Andrew McGregor <andrewmcgr@gmail.com>,
	Matt Smith <smithm@qca.qualcomm.com>,
	Kevin Hayes <hayes@qca.qualcomm.com>,
	Derek Smithies <derek@indranet.co.nz>, netdev@vger.kernel.org
To: Jim Gettys <jg@freedesktop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:18830 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075Ab1H3DeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2011 23:34:25 -0400
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p7U3YNqT032051
	for <netdev@vger.kernel.org>; Mon, 29 Aug 2011 20:34:23 -0700
Received: from iadx2 (iadx2.prod.google.com [10.12.150.2])
	by hpaq5.eem.corp.google.com with ESMTP id p7U3YLRg028720
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 29 Aug 2011 20:34:22 -0700
Received: by iadx2 with SMTP id x2so1380824iad.41
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2011 20:34:21 -0700 (PDT)
In-Reply-To: <4E5C3B47.1050809@freedesktop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Computing the buffering in bytes is better than in packets; but since on
> wireless multicast/broadcast is transmitted at a radically different
> rate than other packets, I expect something based on time is really the
> long term solution; and only the driver has any idea how long a packet
> of a given flavour will likely take to transmit.

The generalization of BQL would be to set the queue limit in terms of
a cost function implemented by the driver.  The cost function would
most likely be an estimate of time to transmit a packet.  So C(P)
could represent cost of a packet, sum(C(P) for P queued) is aggregate
cost of queue packets, and queue limit is the maximum cost sum.  For
wired Ethernet, number of bytes in packet might be a reasonable
function (although framing cost could be included, but I'm not sure
that would make a material difference).  For wireless, maybe the
function could be more complex possibly taking multicast, previous
history of transmission times, or other arbitrary characteristics of
the packet into account...

I can post a new patch with this generalization if this is interesting.

Tom
