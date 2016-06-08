From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] mlxsw: core: Remove deprecated create_workqueue
Date: Wed, 8 Jun 2016 09:55:27 +0200
Message-ID: <20160608075527.GA2201@nanopsycho.orion>
References: <20160607195946.GA11743@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>,
	Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36400 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932447AbcFHHza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 03:55:30 -0400
Received: by mail-wm0-f65.google.com with SMTP id m124so769392wme.3
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 00:55:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160607195946.GA11743@Karyakshetra>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jun 07, 2016 at 09:59:46PM CEST, bhaktipriya96@gmail.com wrote:
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
>respectively. They require forward progress under memory pressure and
>hence, WQ_MEM_RECLAIM has been set.
>
>Since there are only a fixed number of work items, explicit concurrency
>limit is unnecessary here.
>
>Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
