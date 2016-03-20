From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next] net/mlx4_core: Fix backward compatibility on VFs
Date: Sun, 20 Mar 2016 09:21:51 +0200
Message-ID: <CAJ3xEMiKKULxXOrp6QmSCoD1SdXXYk6KLcnn2HdrcucmogpDGg@mail.gmail.com>
References: <1458233382-12871-1-git-send-email-eli@mellanox.com>
	<20160318.231106.2099055485546956238.davem@davemloft.net>
	<20160320070759.GA2935@yuval-lap.uk.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eli Cohen <eli@mellanox.com>, David Miller <davem@davemloft.net>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Alexey Kardashevskiy <aik@ozlabs.ru>
To: Yuval Shaia <yuval.shaia@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33795 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642AbcCTHVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2016 03:21:52 -0400
In-Reply-To: <20160320070759.GA2935@yuval-lap.uk.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 20, 2016 at 9:07 AM, Yuval Shaia <yuval.shaia@oracle.com> wrote:
> On Fri, Mar 18, 2016 at 11:11:06PM -0400, David Miller wrote:
>> From: Eli Cohen <eli@mellanox.com>
>> Date: Thu, 17 Mar 2016 18:49:42 +0200

>> > Commit 85743f1eb345 ("net/mlx4_core: Set UAR page size to 4KB regardless
>> > of system page size") introduced dependency where old VF drivers without
>> > this fix fail to load if the PF driver runs with this commit.
>> > To resolve this add a module parameter which disables that functionality
>> > by default.  If both the PF and VFs are running with a driver with that
>> > commit the administrator may set the module param to true.
>> > The module parameter is called enable_4k_uar.

> Can you consider passing this via comm-channel and save us all from new
> module parameter?
> Suggesting this from sys-admin perspective where (1) making this consist in
> VF and **all** guests would me a nightmare and also (2) take into account
> in public cloud that hypervisor sys-admin is not necessary the same person
> as guest sys-admin.

AFAIK both modified (e.g containing the offending commit) and
non-modified VF drivers
need not be aware to the fix. It should be  a PF only param, where all types of
VF driver keeps working with their source of info being the comm-channel only.

Eli, Yishai, can you confirm this is the case?

Or.
