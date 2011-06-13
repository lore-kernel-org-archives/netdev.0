From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCHv2 RFC 0/4] virtio and vhost-net capacity handling
Date: Mon, 13 Jun 2011 19:02:27 +0530
Message-ID: <OFE36F9C2B.43D9DB04-ON652578AE.0048E1AB-652578AE.004A1462@in.ibm.com>
References: <cover.1307029008.git.mst@redhat.com> <20110607160830.GB17581@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Christian Borntraeger <borntraeger@de.ibm.com>,
	Carsten Otte <cotte@de.ibm.com>, habanero@linux.vnet.ibm.com,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	kvm@vger.kernel.org, lguest@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org,
	linux390@de.ibm.com, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>, steved@us.ibm.com,
	Tom Lendacky <tahm@linux.vnet.ibm.com>,
	virtualization@lists.linux-foundation.org,
	Shirley Ma <xma@us.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([122.248.162.2]:47982 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752445Ab1FMN30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2011 09:29:26 -0400
In-Reply-To: <20110607160830.GB17581@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> wrote on 06/07/2011 09:38:30 PM:

> > This is on top of the patches applied by Rusty.
> >
> > Warning: untested. Posting now to give people chance to
> > comment on the API.
>
> OK, this seems to have survived some testing so far,
> after I dropped patch 4 and fixed build for patch 3
> (build fixup patch sent in reply to the original).
>
> I'll be mostly offline until Sunday, would appreciate
> testing reports.

Hi Michael,

I ran the latest patches with 1K I/O (guest->local host) and
the results are (60 sec run for each test case):

______________________________
#sessions   BW%       SD%
______________________________
1           -25.6     47.0
2           -29.3     22.9
4              .8     1.6
8             1.6     0
16          -1.6      4.1
32          -5.3      2.1
48           11.3    -7.8
64          -2.8      .7
96          -6.2      .6
128         -10.6     12.7
______________________________
BW: -4.8     SD: 5.4

I tested it again to see if the regression is fleeting (since
the numbers vary quite a bit for 1K I/O even between guest->
local host), but:

______________________________
#sessions  BW%     SD%
______________________________
1          14.0    -17.3
2          19.9    -11.1
4          7.9     -15.3
8          9.6     -13.1
16         1.2     -7.3
32        -.6      -13.5
48        -28.7     10.0
64        -5.7     -.7
96        -9.4     -8.1
128       -9.4      .7
______________________________
BW: -3.7     SD: -2.0


With 16K, there was an improvement in SD, but
higher sessions seem to slightly degrade BW/SD:

______________________________
#sessions  BW%      SD%
______________________________
1          30.9    -25.0
2          16.5    -19.4
4         -1.3      7.9
8          1.4      6.2
16         3.9     -5.4
32         0        4.3
48        -.5        .1
64         32.1    -1.5
96        -2.1      23.2
128       -7.4      3.8
______________________________
BW: 5.0          SD: 7.5


Thanks,

- KK

