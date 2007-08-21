From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP ports
	from the host TCP port space.
Date: Mon, 20 Aug 2007 23:58:04 -0700 (PDT)
Message-ID: <20070820.235804.85409183.davem@davemloft.net>
References: <adatzqxwh56.fsf@cisco.com>
	<20070817.234405.66176298.davem@davemloft.net>
	<adalkc5u1o9.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adalkc5u1o9.fsf@cisco.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 20 Aug 2007 18:16:54 -0700

> And direct data placement really does give you a factor of two at
> least, because otherwise you're stuck receiving the data in one
> buffer, looking at some of the data at least, and then figuring out
> where to copy it.  And memory bandwidth is if anything becoming more
> valuable; maybe LRO + header splitting + page remapping tricks can get
> you somewhere but as NCPUS grows then it seems the TLB shootdown cost
> of page flipping is only going to get worse.

As Herbert has said already, people can code for this just like
they have to code for RDMA.

There is no fundamental difference from converting an application
to sendfile or similar.

The only thing this needs is a
"recvmsg_I_dont_care_where_the_data_is()" call.  There are no alignment
issues unless you are trying to push this data directly into the
page cache.

Couple this with a card that makes sure that on a per-page basis, only
data for a particular flow (or group of flows) will accumulate.

People already make cards that can do stuff like this, it can be done
statelessly with an on-chip dynamically maintained flow table.

And best yet it doesn't turn off every feature in the networking nor
bypass it for the actual protocol processing.
