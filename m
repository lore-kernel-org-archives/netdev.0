From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH net-next 3/3] virtio-net: Add accelerated RFS support
Date: Sat, 18 Jan 2014 14:19:30 +0000
Message-ID: <1390054770.16433.20.camel@deadeye.wl.decadent.org.uk>
References: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
	 <1389795654-28381-4-git-send-email-zwu.kernel@gmail.com>
	 <1389907887.11912.87.camel@bwh-desktop.uk.level5networks.com>
	 <CAEH94LjHcxkXLvs6AMNop_yzKG0zaT2mAgsAb21i+RtMbkXbmQ@mail.gmail.com>
	 <1389914188.11912.146.camel@bwh-desktop.uk.level5networks.com>
	 <CAEH94LgKJ0qThGHS-hqXsYKqOe+ns2pRi-wfZy=af1RMejOZ5A@mail.gmail.com>
	 <1389979208.27141.11.camel@bwh-desktop.uk.level5networks.com>
	 <CA+mtBx8eRuWpYkYoPbuCaO1h0Y+g96zJB96zP17ZixOwZ1_gmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Zhi Yong Wu <zwu.kernel@gmail.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:52460 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032AbaAROTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 09:19:34 -0500
In-Reply-To: <CA+mtBx8eRuWpYkYoPbuCaO1h0Y+g96zJB96zP17ZixOwZ1_gmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-17 at 20:59 -0800, Tom Herbert wrote:
> Ben,
> 
> I've never quite understood why flow management in aRFS has to be done
> with separate messages, and if I recall this seems to mitigate
> performance gains to a large extent. It seems like we should be able
> to piggyback on a TX descriptor for a connection information about the
> RX side for that connection, namely the rxhash and queue mapping.
> State creation should be implicit by just seeing a new rxhash value,
> tear down might be accomplished with a separate flag on the final TX
> packet on the connection (this would need some additional logic in the
> stack). Is this method not feasible in either NICs or virtio-net?

Well that's roughly how Flow Director works, isn't it?  So it is
feasible on at least one NIC!  It might be possible to implement
something like that in firmware on the SFC9100 (with the filter based on
the following packet headers, not a hash), but I don't know.  As for
other vendors - I have no idea.

Inserting filters from the receive path seemed like a natural extension
of the software RFS implementation.  And it means that the hardware
filters are inserted a little earlier (no need to transmit another
packet), but maybe that doesn't matter much.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
