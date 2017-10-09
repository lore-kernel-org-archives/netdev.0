From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: make ->ndo_get_phys_port_name accept 32-bit len
Date: Sun, 08 Oct 2017 21:14:55 -0700 (PDT)
Message-ID: <20171008.211455.636113197326702869.davem@davemloft.net>
References: <20171007221917.GA2467@avx2>
        <20171008182545.171498a2@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org,
        michael.chan@broadcom.com, saeedm@mellanox.com,
        simon.horman@netronome.com, jiri@mellanox.com,
        ecree@solarflare.com, vivien.didelot@savoirfairelinux.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38874 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750790AbdJIEO4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:14:56 -0400
In-Reply-To: <20171008182545.171498a2@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Sun, 8 Oct 2017 18:25:45 -0700

> On Sun, 8 Oct 2017 01:19:17 +0300, Alexey Dobriyan wrote:
>> Buffer length passed into this hook is always IFNAMSIZ which is 16.
>> 
>> Code savings on x86_64:
>> 
>> 	add/remove: 0/0 grow/shrink: 1/9 up/down: 2/-45 (-43)
>> 	function                                     old     new   delta
>> 	rocker_cmd_get_port_settings_phys_name_proc     179     181      +2
>> 	rocker_port_get_phys_port_name                62      61      -1
>> 	mlxsw_sx_port_get_phys_port_name              54      50      -4
>> 	mlx5e_rep_get_phys_port_name                  61      57      -4
>> 	efx_get_phys_port_name                        50      46      -4
>> 	dsa_slave_get_phys_port_name                  54      50      -4
>> 	bnxt_vf_rep_get_phys_port_name                69      65      -4
>> 	bnxt_get_phys_port_name                       70      65      -5
>> 	mlxsw_sp_port_get_phys_port_name             116     107      -9
>> 	nfp_port_get_phys_port_name                  180     170     -10
>> 
>> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> 
> I don't think the gains justify the additional burden on backports.

Yeah I agree, this one is not really worth the pain.
