From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: RE: mlx4: smatch stuff: saving error codes in u8
Date: Thu, 15 Dec 2011 09:05:46 +0000
Message-ID: <953B660C027164448AE903364AC447D2485F57EE@MTLDAG02.mtl.com>
References: <20111215084812.GA20924@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:44874 "HELO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752517Ab1LOJHJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 04:07:09 -0500
In-Reply-To: <20111215084812.GA20924@elgon.mountain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Yevgeny,
> 
> Smatch complains about some recent changes to the mlx4 driver:
> drivers/net/ethernet/mellanox/mlx4/cmd.c +364 mlx4_slave_cmd(27)
> 	warn: assigning -22 to unsigned variable 'vhcr->status'
> 
> We should be using the mlx4_status_to_errno() function here to
> translate
> the hardware error codes to linux error codes.
> 
> Also "ret" here gets passed to the the callers who again save it to
> vhcr_cmd->status = __mlx4_cmd() in mlx4_master_process_vhcr().  The
> __mlx4_cmd() function only returns linux error codes, not hardware
> error
> codes.
> 
> Also the mlx4_master_process_vhcr() function sets vhcr_cmd->status to
> linux error codes (which is a mistake) but it doesn't set "ret" on all
> paths so it sometimes returns success even though an error occured
> (which is a second separate mistake).
> 

Thanks Dan,
Will send fixes to this ASAP.
