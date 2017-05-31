From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH] qed: Fix a sleep-in-interrupt bug in qed_int_sp_dpc
Date: Wed, 31 May 2017 17:59:58 +0000
Message-ID: <BLUPR0701MB2004251BB71BADD16789022A8DF10@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <1496240608-17453-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496240608-17453-1-git-send-email-baijiaju1990@163.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The driver may sleep in interrupt handling, and the function call path is=
:
> qed_int_sp_dpc (tasklet_init indicates it handles interrupt)
>   qed_int_attentions
>     qed_mcp_handle_events
>       qed_mcp_handle_link_change
>         qed_link_update
>           qed_fill_link
>             qed_mcp_get_media_type
>               qed_ptt_acquire
>                 usleep_range --> may sleep
>=20
> To fix it, the "usleep_range" is replaced with "udelay".

Thanks for pointing this out, but I believe the fix isn't the right one.

The better option would be to propagate the PTT from the outside
instead of acquiring a new one - in the call stack you've shared
qed_mcp_link_change() held a PTT entry and we could have propagated
it all the way through.

I'll try sending a fix for this in the next couple of days.
