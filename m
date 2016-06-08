From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH] mlxsw: core: Remove deprecated create_workqueue
Date: Wed, 8 Jun 2016 10:53:24 +0300
Message-ID: <20160608075324.GA4824@colbert.mtl.com>
References: <20160607195946.GA11743@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jiri Pirko <jiri@mellanox.com>, Tejun Heo <tj@kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0077.outbound.protection.outlook.com ([157.56.112.77]:2849
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932331AbcFHHz3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2016 03:55:29 -0400
Content-Disposition: inline
In-Reply-To: <20160607195946.GA11743@Karyakshetra>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jun 07, 2016 at 10:59:46PM IDT, bhaktipriya96@gmail.com wrote:
>alloc_workqueue replaces deprecated create_workqueue().
>
>A dedicated workqueue has been used since the workqueue
>mlxsw_wq is used for FDB notif. processing with workitems that are
>involved in normal device operation && because it's a network device
>which can be depended upon during memory reclaim.
>
>Workitems &trans->timeout_dw and &mlxsw_sp->fdb_notify.dw,
>map to mlxsw_sp_fdb_notify_work (processes FDB notifications from the
>underlying device and resolves the netdev to which the entry points to
>and notifies the bridge using the switchdev notifier) and
>mlxsw_emad_trans_timeout_work (provides async EMAD register access)
>respectively.

The ordering here is off - timeout_dw is for
mlxsw_emad_trans_timeout_work() and fdb_notify.dw is for
mlxsw_sp_fdb_notify_work(), but otherwise this seems fine to me.

Tested-by: Ido Schimmel <idosch@mellanox.com>

Thanks!
