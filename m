From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [RFC 2/6] qed: Add iSCSI out of order packet handling.
Date: Thu, 20 Oct 2016 12:58:13 +0000
Message-ID: <BL2PR07MB2306CA84C34D4F67EA5335C28DD50@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1476853273-22960-1-git-send-email-manish.rangankar@cavium.com>
 <1476853273-22960-3-git-send-email-manish.rangankar@cavium.com>
 <f8c5d8d1-0e69-00c2-9349-de611c4b6c08@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "martin.petersen@oracle.com" <martin.petersen@oracle.com>,
        "jejb@linux.vnet.ibm.com" <jejb@linux.vnet.ibm.com>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Dept-Eng QLogic Storage Upstream"
        <QLogic-Storage-Upstream@cavium.com>,
        "Easi, Arun" <Arun.Easi@cavium.com>
To: Hannes Reinecke <hare@suse.de>,
        "Rangankar, Manish" <Manish.Rangankar@cavium.com>,
        "lduncan@suse.com" <lduncan@suse.com>,
        "cleech@redhat.com" <cleech@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0085.outbound.protection.outlook.com ([104.47.33.85]:30737
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932943AbcJTM6U (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Oct 2016 08:58:20 -0400
In-Reply-To: <f8c5d8d1-0e69-00c2-9349-de611c4b6c08@suse.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > This patch adds out of order packet handling for hardware offloaded
> > iSCSI. Out of order packet handling requires driver buffer allocation
> > and assistance.
> >
> > Signed-off-by: Arun Easi <arun.easi@cavium.com>
> > Signed-off-by: Yuval Mintz <yuval.mintz@cavium.com>
> >
> Hmm. The entire out-of-order handling is pretty generic. I really wonder
> if this doesn't apply to iSCSI in general; surely iscsi_tcp suffers from
> the same problem, no?
> If so, wouldn't it be better to move it into generic (iSCSI) code so
> that all implementations would benefit from it?

[disclaimer - I'm far from knowledgeable in iscsi ]

I agree that the problem of out-of-order handling is probably generic,
but our solution is very device oriented.
As the device lacks [a lot of] internal memory, it uses the host memory
for out-of-order buffers and the driver assistance in pushing them when
they are needed.
>From driver perspective, all the data is completely opaque; All it does is
follow the firmware's guidance in storing & re-transmitting buffers when
required.

Now, I guess the logic could be divided between hardware-specifics -
Interaction with 'client' [in our case, device's firmware], to receive
new data, instructions regarding placement and re-transmission,
and a lower generic data structure which supports manipulation of
buffers [push-left, push-right, join, etc.].

But given that the data-structure would completely lacks all
protocol-knowledge [as our implementation doesn't have nor require such],
I think there would be very little gain - we might find out that as much
as 80% of the code is device interaction, and the remaining so-called
'generic' data-structure won't be that useful to other clients as it was
closely tied to our device needs and API.

Either way, placing this under iscsi would probably be insufficient for our
future needs, as our qed-iwarp driver would also require this functionality=
.

Thanks,
Yuval
