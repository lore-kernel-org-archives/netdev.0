From: Alex Duyck <aduyck@mirantis.com>
Subject: Re: [net-next PATCH 04/15] bnxt: Replace ndo_add/del_vxlan_port with ndo_add/del_udp_enc_port
Date: Mon, 13 Jun 2016 12:16:28 -0700
Message-ID: <CAMt9YRqjsDGiZ9b+qaCYPrhJD_p7O5jPAk14nmbr_B0y54FHdw@mail.gmail.com>
References: <20160613173750.15186.24381.stgit@localhost.localdomain>
 <20160613174822.15186.55819.stgit@localhost.localdomain> <CAEh+42jyXOytgidZN4MNBoPaKL-xoQDXptFqnbhWrMGc5=8z=w@mail.gmail.com>
 <55c86ee3-4974-147e-c09a-a88f202fc3c4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org, Jiri Benc <jbenc@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	saeedm@mellanox.com, Ariel Elior <ariel.elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Dept-GELinuxNICDev@qlogic.com, David Miller <davem@davemloft.net>,
	eugenia@mellanox.com
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:36746 "EHLO
	mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423278AbcFMTQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 15:16:40 -0400
Received: by mail-vk0-f46.google.com with SMTP id u64so80651195vkf.3
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 12:16:39 -0700 (PDT)
In-Reply-To: <55c86ee3-4974-147e-c09a-a88f202fc3c4@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2016 at 12:14 PM, Hannes Frederic Sowa
<hannes@redhat.com> wrote:
> On 13.06.2016 20:41, Jesse Gross wrote:
>> On Mon, Jun 13, 2016 at 10:48 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
>>> This change replaces the network device operations for adding or removing a
>>> VXLAN port with operations that are more generically defined to be used for
>>> any UDP offload port but provide a type.  As such by just adding a line to
>>> verify that the offload type if VXLAN we can maintain the same
>>> functionality.
>>>
>>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>>
>> It looks like bnxt actually has a hardcoded offload of the Geneve port
>> rather than using the registration (maybe it predated it?). It would
>> be nice to incorporate that into your unified handler as well.
>>
>> I think you could actually just kill all of these
>> CONFIG_VXLAN/CONFIG_GENEVE checks (across all the drivers, not just
>> this one). They shouldn't be necessary any more now that there's no
>> longer strong linkage to the tunnel drivers.
>
> Yes, agreed. We can remove the CONFIG_VXLAN and CONFIG_GENEVE stuff now.
> But I think this can be a separate series.

Actually it should be pretty easy to do all of this in the same
series.  I am directly effecting the code where it is wrapped up
anyway.  Dropping the defines will make this easier for me to test.

- Alex
