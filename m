From: Hannes Reinecke <hare@suse.de>
Subject: Re: [PATCH v3 2/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Tue, 25 Sep 2007 10:39:17 +0200
Message-ID: <46F8C935.8050907@suse.de>
References: <20070908084127G.tomof@acm.org> <46E2884B.2070107@garzik.org> <20070908120036.GB8478@infradead.org> <20070909061551G.tomof@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: open-iscsi@googlegroups.com, hch@infradead.org, jeff@garzik.org,
	davem@davemloft.net, mchristi@redhat.com, netdev@vger.kernel.org,
	anilgv@broadcom.com, talm@broadcom.com, lusinsky@broadcom.com,
	uri@broadcom.com, fujita.tomonori@lab.ntt.co.jp
To: tomof@acm.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60910 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756766AbXIYIjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2007 04:39:22 -0400
In-Reply-To: <20070909061551G.tomof@acm.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tomo,

=46UJITA Tomonori wrote:
> On Sat, 8 Sep 2007 13:00:36 +0100
> Christoph Hellwig <hch@infradead.org> wrote:
>=20
>> On Sat, Sep 08, 2007 at 07:32:27AM -0400, Jeff Garzik wrote:
>>> FUJITA Tomonori wrote:
>>>> Yeah, iommu code ignores the lld limitations (the problem is that =
the
>>>> lld limitations are in request_queue and iommu code can't access t=
o
>>>> request_queue). There is no way to tell iommu code about the lld
>>>> limitations.
>>>
>>> This fact very much wants fixing.
>>
>> Absolutely.  Unfortunately everyone wastes their time on creating wo=
rkarounds
>> instead of fixing the underlying problem.
>=20
> Any ideas on how to fix this?
>=20
> I chatted to Jens and James on this last week.
>=20
> - we could just copies the lld limitations to device structure. it's
> hacky but device structure already has hacky stuff.
>=20
> - we could just link device structure to request_queue structure so
> that iommu code can see request_queue structure.
>=20
> - we could remove the lld limitations in request_queue strucutre and
> have a new strucutre (something like struct io_restrictions). then
> somehow we could link the new structure with request_queue and device
> strucutres.
>=20
I'd prefer the latter. These struct io_restrictions could then be used
by dm (which has it's own version right now) to merge queue capabilitie=
s.

Cheers,

Hannes
--=20
Dr. Hannes Reinecke		      zSeries & Storage
hare@suse.de			      +49 911 74053 688
SUSE LINUX Products GmbH, Maxfeldstr. 5, 90409 N=FCrnberg
GF: Markus Rex, HRB 16746 (AG N=FCrnberg)
