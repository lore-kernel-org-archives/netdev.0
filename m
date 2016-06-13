From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [net-next PATCH 04/15] bnxt: Replace ndo_add/del_vxlan_port with ndo_add/del_udp_enc_port
Date: Mon, 13 Jun 2016 12:16:42 -0700
Message-ID: <CACKFLi=opqb393SGEKLgN-cvQn7xL8kYVr+=MhW7SO41-xPJZQ@mail.gmail.com>
References: <20160613173750.15186.24381.stgit@localhost.localdomain>
	<20160613174822.15186.55819.stgit@localhost.localdomain>
	<CAEh+42jyXOytgidZN4MNBoPaKL-xoQDXptFqnbhWrMGc5=8z=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Jiri Benc <jbenc@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Dept-GELinuxNICDev@qlogic.com, David Miller <davem@davemloft.net>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:36654 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423278AbcFMTQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 15:16:44 -0400
Received: by mail-oi0-f49.google.com with SMTP id p204so222864202oih.3
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 12:16:43 -0700 (PDT)
In-Reply-To: <CAEh+42jyXOytgidZN4MNBoPaKL-xoQDXptFqnbhWrMGc5=8z=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2016 at 11:41 AM, Jesse Gross <jesse@kernel.org> wrote:
> On Mon, Jun 13, 2016 at 10:48 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
>> This change replaces the network device operations for adding or removing a
>> VXLAN port with operations that are more generically defined to be used for
>> any UDP offload port but provide a type.  As such by just adding a line to
>> verify that the offload type if VXLAN we can maintain the same
>> functionality.
>>
>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>
> It looks like bnxt actually has a hardcoded offload of the Geneve port
> rather than using the registration (maybe it predated it?).

It's not hardcoded.  The driver code just predated the ndo geneve calls.

>  It would
> be nice to incorporate that into your unified handler as well.
>
> I think you could actually just kill all of these
> CONFIG_VXLAN/CONFIG_GENEVE checks (across all the drivers, not just
> this one). They shouldn't be necessary any more now that there's no
> longer strong linkage to the tunnel drivers.

Agreed.
