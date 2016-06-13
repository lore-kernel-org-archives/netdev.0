From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [net-next PATCH 04/15] bnxt: Replace ndo_add/del_vxlan_port with
 ndo_add/del_udp_enc_port
Date: Mon, 13 Jun 2016 21:14:41 +0200
Message-ID: <55c86ee3-4974-147e-c09a-a88f202fc3c4@redhat.com>
References: <20160613173750.15186.24381.stgit@localhost.localdomain>
 <20160613174822.15186.55819.stgit@localhost.localdomain>
 <CAEh+42jyXOytgidZN4MNBoPaKL-xoQDXptFqnbhWrMGc5=8z=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org, Jiri Benc <jbenc@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	saeedm@mellanox.com, Ariel Elior <ariel.elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Dept-GELinuxNICDev@qlogic.com, David Miller <davem@davemloft.net>,
	eugenia@mellanox.com
To: Jesse Gross <jesse@kernel.org>,
	Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53226 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424510AbcFMTOz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2016 15:14:55 -0400
In-Reply-To: <CAEh+42jyXOytgidZN4MNBoPaKL-xoQDXptFqnbhWrMGc5=8z=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13.06.2016 20:41, Jesse Gross wrote:
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
> rather than using the registration (maybe it predated it?). It would
> be nice to incorporate that into your unified handler as well.
> 
> I think you could actually just kill all of these
> CONFIG_VXLAN/CONFIG_GENEVE checks (across all the drivers, not just
> this one). They shouldn't be necessary any more now that there's no
> longer strong linkage to the tunnel drivers.

Yes, agreed. We can remove the CONFIG_VXLAN and CONFIG_GENEVE stuff now.
But I think this can be a separate series.

Bye,
Hannes
