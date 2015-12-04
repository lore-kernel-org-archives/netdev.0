From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: [PATCH] net: thunderx: Remove unnecessary struct nicpf::lmac_cnt
Date: Fri, 4 Dec 2015 23:11:00 +0530
Message-ID: <CA+sq2CejiQ1En32_26=Ub6haNgAW2HaKAMPpgVCMCds5ny1VcQ@mail.gmail.com>
References: <1449242242-9036-1-git-send-email-p.fedin@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>, youngmin.lee@cavium.com,
	kin-yip.liu@cavium.com
To: Pavel Fedin <p.fedin@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:34525 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937AbbLDRlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 12:41:02 -0500
Received: by wmvv187 with SMTP id v187so85262125wmv.1
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2015 09:41:00 -0800 (PST)
In-Reply-To: <1449242242-9036-1-git-send-email-p.fedin@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>num_vf_en and lmac_cnt are always equal.However in future this may change.
Yes these two won't be equal in future and hence a differentiation is needed.
lmac_cnt will have to point to no of physical interfaces and num_vf_en
to logical interfaces.
num_vf_en will default to lmac_cnt but with 'sriov_configure' can be increased.

>The worst consequence of this is failure to deliver link status
> messages, causing VFs to go defunct
There is no point in delivering link status to all VFs, as
irrespective of physical link
status, VFs (attached to VMs) should be able to communicate. A
differentiation here
will also be needed then.

-       for (vf = 0; vf < nic->lmac_cnt; vf++) {
+       for (vf = 0; vf < nic->num_vf_en; vf++) {
This is incorrect, if in future this refers to logical interfaces
which may be greater than
physical interface count then below references will fail.

/* Get BGX, LMAC indices for the VF */
bgx = NIC_GET_BGX_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vf]);
lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vf]);


Thanks,
Sunil.
