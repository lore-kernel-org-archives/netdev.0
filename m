From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next 2/2] bnx2x: allocate mac filtering pending list
 in PAGE_SIZE increments
Date: Tue, 20 Sep 2016 15:00:23 +0000
Message-ID: <BL2PR07MB2306ECB3DBAB53BFB9CF30EC8DF70@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <cover.1474060371.git.jbaron@akamai.com>
 <d46b4fa36c32affff20fcc92148e33ee6176f899.1474060371.git.jbaron@akamai.com>
 <BL2PR07MB2306CEA6AD75D9D4EB77FB1F8DF50@BL2PR07MB2306.namprd07.prod.outlook.com>
 <57E02F82.9060903@akamai.com>
 <BL2PR07MB23061EAE5CF41EE56A1ED99B8DF70@BL2PR07MB2306.namprd07.prod.outlook.com>
 <57E14D24.40504@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Ariel.Elior@qlogic.com" <Ariel.Elior@qlogic.com>
To: Jason Baron <jbaron@akamai.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0047.outbound.protection.outlook.com ([104.47.33.47]:40831
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932189AbcITPA0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 11:00:26 -0400
In-Reply-To: <57E14D24.40504@akamai.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > The question I rose was whether it actually makes a difference under
> > such circumstances whether the device would actually filter those
> > multicast addresses or be completely multicast promiscuous.
> > e.g., whether it's significant to be filtering out multicast ingress
> > traffic when you're already allowing 1/2 of all random multicast
> > packets to be classified for the interface.
> >
>=20
> Agreed, I think this is the more interesting question here. I thought tha=
t we
> would want to make sure we are using most of the bins before falling back=
 to
> multicast ingress. The reason being that even if its more expensive for t=
he NIC to
> do the filtering than the multicast mode, it would be more than made up f=
or by
> having to drop the traffic higher up the stack. So I think if we can dete=
rmine the
> percent of the bins that we want to use, we can then back into the averag=
e
> number of filters required to get there. As I said, I thought we would wa=
nt to
> make sure we filled basically all the bins (with a high probability that =
is) before
> falling back to multicast, and so I threw out 2,048.

AFAIK configuring multiple filters doesn't incur any performance penalty
from the adapter side.
And I agree that from 'offloading' perspective it's probably better to
filter in HW even if the gain is negligible.=20
So for the upper limit - there's not much of a reason to it; The only gain
would be to prevent driver from allocating lots-and-lots of memory
temporarily for an unnecessary configuration.
