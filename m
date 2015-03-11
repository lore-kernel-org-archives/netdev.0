From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 1/1] net: fec: fix oops after transmit queue timeout
Date: Wed, 11 Mar 2015 14:12:42 -0300
Message-ID: <CAOMZO5DJPi+cZEQnO1qkWNXMc+=pboFz-z_rzxwxESD3G_1FcA@mail.gmail.com>
References: <1426093216-18370-1-git-send-email-george.joseph@fairview5.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nimrod Andy <B38611@freescale.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: George Joseph <george.joseph@fairview5.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426093216-18370-1-git-send-email-george.joseph@fairview5.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 11, 2015 at 2:00 PM, George Joseph
<george.joseph@fairview5.com> wrote:
> When a transmit queue timeout happens, dev_watchdog calls fec_timeout
> which in turns schedules fec_enet_timeout_work.  fec_enet_timeout_work
> uses container_of to get the private data structure (fep) then tries to
> use fep->netdev.  Unfortunately, nobody ever set fep->netdev so the result
> is a NULL pointer oops.
>
> With fep->netdev set right after fep is allocated in fep_probe, the
> drivers recovers nicely after the tx queue timeout.
>
> Signed-off-by: George Joseph <george.joseph@fairview5.com>
> Tested-by: George Joseph <george.joseph@fairview5.com>

Thanks for the patch, but this has already been fixed by:

commit 0c8185944a125621a1766615585238a3563ccac3
Author: Hubert Feurstein <h.feurstein@gmail.com>
Date:   Wed Jan 7 14:48:17 2015 +0100

    net: fec: fix NULL pointer dereference in fec_enet_timeout_work

    This patch initialises the fep->netdev pointer. This pointer was not
    initialised at all, but is used in fec_enet_timeout_work and in some
    error paths.

    Signed-off-by: Hubert Feurstein <h.feurstein@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
