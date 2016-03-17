From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] iwlwifi: dvm: convert create_singlethread_workqueue()
 to alloc_workqueue()
Date: Thu, 17 Mar 2016 13:43:22 +0100
Message-ID: <1458218602.2158.17.camel@sipsolutions.net>
References: <1458218246-18807-1-git-send-email-eraretuya@gmail.com>
	 (sfid-20160317_133935_577395_D13DECC0)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: emmanuel.grumbach@intel.com, linuxwifi@intel.com,
	kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, tj@kernel.org
To: Eva Rachel Retuya <eraretuya@gmail.com>,
	outreachy-kernel@googlegroups.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458218246-18807-1-git-send-email-eraretuya@gmail.com> (sfid-20160317_133935_577395_D13DECC0)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-03-17 at 20:37 +0800, Eva Rachel Retuya wrote:
> Use alloc_workqueue() to allocate the workqueue instead of
> create_singlethread_workqueue() since the latter is deprecated and is
> scheduled for removal.

Scheduled where?

> =C2=A0static void iwl_setup_deferred_work(struct iwl_priv *priv)
> =C2=A0{
> -	priv->workqueue =3D create_singlethread_workqueue(DRV_NAME);
> +	priv->workqueue =3D alloc_workqueue(DRV_NAME, WQ_HIGHPRI |
> WQ_UNBOUND |
> +					=C2=A0=C2=A0WQ_MEM_RECLAIM, 1);

Seems like you should use=C2=A0alloc_ordered_workqueue() though? That a=
lso
gets you UNBOUND immediately, and the "1".

I'm not really sure HIGHPRI is needed either.

johannes
