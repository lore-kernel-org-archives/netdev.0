From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Sun, 12 Aug 2012 08:40:13 -0700
Message-ID: <877gt415lu.fsf@xmission.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
	<1343840975-3252-10-git-send-email-ogerlitz@mellanox.com>
	<87boitz044.fsf@xmission.com> <20120805185031.GA18640@redhat.com>
	<CAJZOPZKtdvxTGvrxj+T896mEexb=yN9s1cCuqUmhhzCOvUPEnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Erez Shitrit <erezsh@mellanox.co.il>,
	Doug Ledford <dledford@redhat.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:60926 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032Ab2HLPk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Aug 2012 11:40:26 -0400
In-Reply-To: <CAJZOPZKtdvxTGvrxj+T896mEexb=yN9s1cCuqUmhhzCOvUPEnA@mail.gmail.com>
	(Or Gerlitz's message of "Wed, 8 Aug 2012 08:23:15 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <or.gerlitz@gmail.com> writes:

> On Sun, Aug 5, 2012 at 9:50 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
>
> [...]
>> So it seems that a sane solution would involve an extra level of
>> indirection, with guest addresses being translated to host IB addresses.
>> As long as you do this, maybe using an ethernet frame format makes sense.
> [...]
>
> Yep, that's among the points we're trying to make, the way you've put
> it makes it clearer.
>
>> - IGMP/MAC snooping in a driver is just too hairy.
>
> mmm, any rough idea/direction how to do that otherwise?

Let me give you a non-hack recomendation.

- Give up on being wire compatible with IPoIB.

- Define and implement ethernet over inifiniband aka EoIB.

With EoIB:
- The SM would map ethernet address to inifiniband hardware addresses.
- You discover which multicast addresses are of interest from the
  IP layer above so no snooping is necessary.
- You could run queue pairs directly to hosts.

Shrug.  It is trivial and it will work.  It will probably run into the
same problems that have historically been a problem for using IPoIB
(lack of stateless offloads) but shrug that is mostly a NIC firmware
problem.  The switches will have no trouble and interoperability will
be assured.

If you want to map ethernet over infiniband please map ethernet over
infiniband.  Don't poorly NAT ethernet into infiniband.

Eric
