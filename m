From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] net: wireless: marvell: libertas: Remove create_workqueue
Date: Sat, 04 Jun 2016 17:29:20 +0300
Message-ID: <87h9d9t4cf.fsf@kamboji.qca.qualcomm.com>
References: <20160604135901.GA29897@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Kemnade <andreas@kemnade.info>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	"Andrew F. Davis" <afd@ti.com>,
	Jonathan Cameron <jic23@kernel.org>,
	Mark Brown <broonie@kernel.org>, Tejun Heo <tj@kernel.org>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160604135901.GA29897@Karyakshetra> (Bhaktipriya Shridhar's
	message of "Sat, 4 Jun 2016 19:29:01 +0530")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bhaktipriya Shridhar <bhaktipriya96@gmail.com> writes:

> alloc_workqueue replaces deprecated create_workqueue().
>
> In if_sdio.c, the workqueue card->workqueue has workitem
> &card->packet_worker, which is mapped to if_sdio_host_to_card_worker.
> The workitem is involved in sending packets to firmware.
> Forward progress under memory pressure is a requirement here.
>
> In if_spi.c, the workqueue card->workqueue has workitem
> &card->packet_worker, which is mapped to if_spi_host_to_card_worker.
> The workitem is involved in sending command packets from the host.
> Forward progress under memory pressure is a requirement here.
>
> Dedicated workqueues have been used in both cases since the workitems
> on the workqueues are involved in normal device operation with
> WQ_MEM_RECLAIM set to gurantee forward progress under memory pressure.
> Since there are only a fixed number of work items, explicit concurrency
> limit is unnecessary.
>
> flush_workqueue is unnecessary since destroy_workqueue() itself calls
> drain_workqueue() which flushes repeatedly till the workqueue
> becomes empty. Hence the calls to flush_workqueue() before
> destroy_workqueue() have been dropped.
>
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>

"libertas:" as a prefix is enough, no need to put the full path to the
title. I can fix that this time.

You can actually check yourself what prefix is commonly used in a
particular file or directory:

$ git log --oneline --no-merges -10 drivers/net/wireless/marvell/libertas/
57fbcce37be7 cfg80211: remove enum ieee80211_band
3691ac4a9c95 libertas: fix an error code in probe
143e49458424 libertas: add an cfg80211 interface for powersaving
0b8802dc5f59 libertas: fix ps-mode related removal problems
fada24a54770 libertas: go back to ps mode without commands pending
57954b94cad7 libertas: do not confirm sleep if commands are pending
fae4f9f78ab1 libertas: check whether bus can do more than polling
0a7701b4defc libertas: fix pointer bugs for PS_MODE commands
6d91ff7acc90 libertas: cleanup a variable name
0a38c8e1b592 libertas: check for NULL before use
$
-- 
Kalle Valo
