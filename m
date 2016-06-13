From: Jesse Gross <jesse@kernel.org>
Subject: Re: [net-next PATCH 04/15] bnxt: Replace ndo_add/del_vxlan_port with ndo_add/del_udp_enc_port
Date: Mon, 13 Jun 2016 11:41:01 -0700
Message-ID: <CAEh+42jyXOytgidZN4MNBoPaKL-xoQDXptFqnbhWrMGc5=8z=w@mail.gmail.com>
References: <20160613173750.15186.24381.stgit@localhost.localdomain> <20160613174822.15186.55819.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Jiri Benc <jbenc@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	saeedm@mellanox.com, Ariel Elior <ariel.elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Dept-GELinuxNICDev@qlogic.com, David Miller <davem@davemloft.net>,
	eugenia@mellanox.com
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:39780 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422632AbcFMSlU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2016 14:41:20 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id D71C220154
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 18:41:18 +0000 (UTC)
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B30E020160
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 18:41:16 +0000 (UTC)
Received: by mail-qk0-f180.google.com with SMTP id c73so49907286qkg.2
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 11:41:16 -0700 (PDT)
In-Reply-To: <20160613174822.15186.55819.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2016 at 10:48 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This change replaces the network device operations for adding or removing a
> VXLAN port with operations that are more generically defined to be used for
> any UDP offload port but provide a type.  As such by just adding a line to
> verify that the offload type if VXLAN we can maintain the same
> functionality.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

It looks like bnxt actually has a hardcoded offload of the Geneve port
rather than using the registration (maybe it predated it?). It would
be nice to incorporate that into your unified handler as well.

I think you could actually just kill all of these
CONFIG_VXLAN/CONFIG_GENEVE checks (across all the drivers, not just
this one). They shouldn't be necessary any more now that there's no
longer strong linkage to the tunnel drivers.
