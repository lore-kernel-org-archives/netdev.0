From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: bnx2x: link detected up at startup even when it should be down
Date: Tue, 25 Sep 2012 14:54:28 +0200
Message-ID: <CAL8zT=j9LC5hKtmkzBA-Epa+NhX1YpC9RodJ-C+UunTH_HRVKQ@mail.gmail.com>
References: <CAL8zT=hFPQ-NZw8eKQwnktRrcpsOFk3aa_ac5mSWa+TAwyTGBQ@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F2EB97C@SJEXCHMB06.corp.ad.broadcom.com>
 <CAL8zT=i_eV3SjuBgdWrBPaE-CoBBVh5QJD8jg-YMoQHDuA4AOQ@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F2F1B50@SJEXCHMB06.corp.ad.broadcom.com>
 <504C9EFCA2D0054393414C9CB605C37F3079E4@SJEXCHMB06.corp.ad.broadcom.com>
 <CAL8zT=gp5uZ-Q36=vw--j35txrnLRhguoiMHi8a1kzX=VC3nJg@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F3086A3@SJEXCHMB06.corp.ad.broadcom.com> <CAL8zT=hJ84woFg0KFxztuTxf2NJEBzThPRXDhZ9KnMJnBxmoZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Barak Witkowski <barak@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:34970 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754733Ab2IYMyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 08:54:50 -0400
Received: by ieak13 with SMTP id k13so13720701iea.19
        for <netdev@vger.kernel.org>; Tue, 25 Sep 2012 05:54:49 -0700 (PDT)
In-Reply-To: <CAL8zT=hJ84woFg0KFxztuTxf2NJEBzThPRXDhZ9KnMJnBxmoZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/9/25 Jean-Michel Hautbois <jhautbois@gmail.com>:
> 2012/9/25 Dmitry Kravkov <dmitry@broadcom.com>:
>>> -----Original Message-----
>>> From: Jean-Michel Hautbois [mailto:jhautbois@gmail.com]
>>> Sent: Tuesday, September 25, 2012 10:11 AM
>>> To: Dmitry Kravkov
>>> Cc: netdev; Barak Witkowski; Eilon Greenstein; davem@davemloft.net
>>> Subject: Re: bnx2x: link detected up at startup even when it should be down
>>>
>>>
>>> I have tested several things, and I added some traces in order to get
>>> information.
>>> For instance, I trace the load_code in the function named "bnx2x_nic_load".
>>>
>>> [   25.693677] bnx2x 0000:04:00.0: eth0: bnx2x_nic_load load_code=0x10130000
>>> [   25.693679] bnx2x 0000:04:00.0: eth0: bnx2x_nic_load start period
>>> [  102.748934] bnx2x 0000:04:00.1: eth1: bnx2x_nic_load load_code=0x10100000
>>> [  102.749065] bnx2x 0000:04:00.1: eth1: bnx2x_nic_load start period
>>> [  104.007074] bnx2x 0000:04:00.2: eth2: bnx2x_nic_load load_code=0x10120000
>>> [  104.007197] bnx2x 0000:04:00.2: eth2: bnx2x_nic_load NOT start period
>>> [  104.423789] bnx2x 0000:04:00.3: eth3: bnx2x_nic_load load_code=0x10120000
>>> [  104.423914] bnx2x 0000:04:00.3: eth3: bnx2x_nic_load NOT start period
>>> [  104.836505] bnx2x 0000:04:00.4: eth4: bnx2x_nic_load load_code=0x10120000
>>> [  104.836632] bnx2x 0000:04:00.4: eth4: bnx2x_nic_load NOT start period
>>> [  105.254220] bnx2x 0000:04:00.5: eth5: bnx2x_nic_load load_code=0x10120000
>>> [  105.254350] bnx2x 0000:04:00.5: eth5: bnx2x_nic_load NOT start period
>>> [  105.667935] bnx2x 0000:04:00.6: eth6: bnx2x_nic_load load_code=0x10120000
>>> [  105.668066] bnx2x 0000:04:00.6: eth6: bnx2x_nic_load NOT start period
>>> [  106.081652] bnx2x 0000:04:00.7: eth7: bnx2x_nic_load load_code=0x10120000
>>> [  106.081779] bnx2x 0000:04:00.7: eth7: bnx2x_nic_load NOT start period
>>>
>>> This is a FlexNIC use.
>>> Here is my (quick and dirty) patch which makes the link detection
>>> working and adds the traces shown above :
>>>
>>> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
>>> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
>>> index 580b44e..dedd810 100644
>>> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
>>> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
>>> @@ -1769,6 +1769,7 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
>>>          */
>>>         if (!BP_NOMCP(bp)) {
>>>                 load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ, 0);
>>> +netdev_info(bp->dev, "bnx2x_nic_load bnx2x_fw_command
>>> load_code=0x%08X\n",load_code);
>>>                 if (!load_code) {
>>>                         BNX2X_ERR("MCP response failure, aborting\n");
>>>                         rc = -EBUSY;
>>> @@ -1785,22 +1786,31 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
>>>                 DP(NETIF_MSG_IFUP, "NO MCP - load counts[%d]      %d, %d, %d\n",
>>>                    path, load_count[path][0], load_count[path][1],
>>>                    load_count[path][2]);
>>> +netdev_info(bp->dev, "bnx2x_nic_load NO MCP - load counts[%d]
>>> %d, %d, %d\n",
>>> +                  path, load_count[path][0], load_count[path][1],
>>> +                  load_count[path][2]);
>>>                 load_count[path][0]++;
>>>                 load_count[path][1 + port]++;
>>>                 DP(NETIF_MSG_IFUP, "NO MCP - new load counts[%d]  %d, %d, %d\n",
>>>                    path, load_count[path][0], load_count[path][1],
>>>                    load_count[path][2]);
>>> +netdev_info(bp->dev, "bnx2x_nic_load NO MCP - new load counts[%d]
>>> %d, %d, %d\n",
>>> +                  path, load_count[path][0], load_count[path][1],
>>> +                  load_count[path][2]);
>>>                 if (load_count[path][0] == 1)
>>>                         load_code = FW_MSG_CODE_DRV_LOAD_COMMON;
>>>                 else if (load_count[path][1 + port] == 1)
>>>                         load_code = FW_MSG_CODE_DRV_LOAD_PORT;
>>>                 else
>>>                         load_code = FW_MSG_CODE_DRV_LOAD_FUNCTION;
>>> +netdev_info(bp->dev, "bnx2x_nic_load autre
>>> load_code=0x%08X\n",load_code);
>>>         }
>>>
>>> +netdev_info(bp->dev, "bnx2x_nic_load load_code=0x%08X\n",load_code);
>>>         if ((load_code == FW_MSG_CODE_DRV_LOAD_COMMON) ||
>>>             (load_code == FW_MSG_CODE_DRV_LOAD_COMMON_CHIP) ||
>>> -           (load_code == FW_MSG_CODE_DRV_LOAD_PORT)) {
>>> +           (load_code == FW_MSG_CODE_DRV_LOAD_PORT) ||
>>> +                (load_code == FW_MSG_CODE_DRV_LOAD_FUNCTION)) {
>>>                 bp->port.pmf = 1;
>>>                 /*
>>>                  * We need the barrier to ensure the ordering between the
>>> @@ -1808,9 +1818,13 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
>>>                  * bnx2x_periodic_task().
>>>                  */
>>>                 smp_mb();
>>> +netdev_info(bp->dev, "bnx2x_nic_load start period\n");
>>>                 queue_delayed_work(bnx2x_wq, &bp->period_task, 0);
>>>         } else
>>> +{
>>> +netdev_info(bp->dev, "bnx2x_nic_load NOT start period\n");
>>>                 bp->port.pmf = 0;
>>> +}
>>>
>>>         DP(NETIF_MSG_LINK, "pmf %d\n", bp->port.pmf);
>>>
>> Thanks Jean,
>> But your output does not suit the patch.
>
> Yes, you are right, here it is :
> Sep 25 07:56:08 debian kernel: [   26.607197] bnx2x 0000:04:00.0:
> eth0: bnx2x_nic_load bnx2x_fw_command load_code=0x10130000
> Sep 25 07:56:08 debian kernel: [   26.608642] bnx2x 0000:04:00.0:
> eth0: bnx2x_nic_load load_code=0x10130000
> Sep 25 07:56:08 debian kernel: [   26.608644] bnx2x 0000:04:00.0:
> eth0: bnx2x_nic_load start period
> Sep 25 07:57:20 debian kernel: [  101.068231] bnx2x 0000:04:00.1:
> eth1: bnx2x_nic_load bnx2x_fw_command load_code=0x10100000
> Sep 25 07:57:20 debian kernel: [  101.068416] bnx2x 0000:04:00.1:
> eth1: bnx2x_nic_load load_code=0x10100000
> Sep 25 07:57:20 debian kernel: [  101.068533] bnx2x 0000:04:00.1:
> eth1: bnx2x_nic_load start period
> Sep 25 07:57:21 debian kernel: [  102.294393] bnx2x 0000:04:00.2:
> eth2: bnx2x_nic_load bnx2x_fw_command load_code=0x10120000
> Sep 25 07:57:21 debian kernel: [  102.294585] bnx2x 0000:04:00.2:
> eth2: bnx2x_nic_load load_code=0x10120000
> Sep 25 07:57:21 debian kernel: [  102.294711] bnx2x 0000:04:00.2:
> eth2: bnx2x_nic_load start period
> Sep 25 07:57:22 debian kernel: [  102.782057] bnx2x 0000:04:00.3:
> eth3: bnx2x_nic_load bnx2x_fw_command load_code=0x10120000
> Sep 25 07:57:22 debian kernel: [  102.782240] bnx2x 0000:04:00.3:
> eth3: bnx2x_nic_load load_code=0x10120000
> Sep 25 07:57:22 debian kernel: [  102.782359] bnx2x 0000:04:00.3:
> eth3: bnx2x_nic_load start period
> Sep 25 07:57:22 debian kernel: [  103.265731] bnx2x 0000:04:00.4:
> eth4: bnx2x_nic_load bnx2x_fw_command load_code=0x10120000
> Sep 25 07:57:22 debian kernel: [  103.265924] bnx2x 0000:04:00.4:
> eth4: bnx2x_nic_load load_code=0x10120000
> Sep 25 07:57:22 debian kernel: [  103.266051] bnx2x 0000:04:00.4:
> eth4: bnx2x_nic_load start period
> Sep 25 07:57:23 debian kernel: [  103.758390] bnx2x 0000:04:00.5:
> eth5: bnx2x_nic_load bnx2x_fw_command load_code=0x10120000
> Sep 25 07:57:23 debian kernel: [  103.758583] bnx2x 0000:04:00.5:
> eth5: bnx2x_nic_load load_code=0x10120000
> Sep 25 07:57:23 debian kernel: [  103.758711] bnx2x 0000:04:00.5:
> eth5: bnx2x_nic_load start period
> Sep 25 07:57:23 debian kernel: [  104.252053] bnx2x 0000:04:00.6:
> eth6: bnx2x_nic_load bnx2x_fw_command load_code=0x10120000
> Sep 25 07:57:23 debian kernel: [  104.252247] bnx2x 0000:04:00.6:
> eth6: bnx2x_nic_load load_code=0x10120000
> Sep 25 07:57:23 debian kernel: [  104.252373] bnx2x 0000:04:00.6:
> eth6: bnx2x_nic_load start period
> Sep 25 07:57:24 debian kernel: [  104.836655] bnx2x 0000:04:00.7:
> eth7: bnx2x_nic_load bnx2x_fw_command load_code=0x10120000
> Sep 25 07:57:24 debian kernel: [  104.836849] bnx2x 0000:04:00.7:
> eth7: bnx2x_nic_load load_code=0x10120000
> Sep 25 07:57:24 debian kernel: [  104.836976] bnx2x 0000:04:00.7:
> eth7: bnx2x_nic_load start period
> Sep 25 07:57:25 debian kernel: [  106.145755] bnx2x 0000:04:00.1:
> eth1: bnx2x_nic_load bnx2x_fw_command load_code=0x10120000
> Sep 25 07:57:25 debian kernel: [  106.145940] bnx2x 0000:04:00.1:
> eth1: bnx2x_nic_load load_code=0x10120000
> Sep 25 07:57:25 debian kernel: [  106.146056] bnx2x 0000:04:00.1:
> eth1: bnx2x_nic_load start period
>
>> Your patch will start periodic for every instance, but printout show that it's started for PMF only (which is correct).
>> Generally if all functions are marked as PMF (port management function) you will get into the problem accessing shared port resources, like phys and internal data structures, then configuration/data will be corrupted.
>>
>> Is it feasible to provide ethtool -i output and syslog when driver is loaded debug=0x4?
> $> ethtool -i eth0
> driver: bnx2x
> version: 1.70.30-1
> firmware-version: bc 7.0.49
> bus-info: 0000:04:00.0
>
> And msglvl set to 4 says this :
> Sep 25 12:29:20 debian kernel: [16410.336897] bnx2x:
> [bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
> Sep 25 12:29:20 debian kernel: [16410.337215] bnx2x:
> [bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
> Sep 25 12:29:20 debian kernel: [16410.337511] bnx2x:
> [bnx2x_get_settings:251(eth2)]ethtool_cmd: cmd 1
> Sep 25 12:29:21 debian kernel: [16410.395363] bnx2x:
> [bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
> Sep 25 12:29:21 debian kernel: [16410.633207] bnx2x:
> [bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
> Sep 25 12:29:21 debian kernel: [16411.174842] bnx2x:
> [bnx2x_set_aer_mmd:3342(eth2)]Set AER to 0x0
> Sep 25 12:29:22 debian kernel: [16411.396739] bnx2x:
> [bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
> Sep 25 12:29:22 debian kernel: [16411.432249] bnx2x:
> [bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
> Sep 25 12:29:22 debian kernel: [16411.432566] bnx2x:
> [bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
> Sep 25 12:29:22 debian kernel: [16411.433348] bnx2x:
> [bnx2x_get_settings:251(eth2)]ethtool_cmd: cmd 1
> Sep 25 12:29:22 debian kernel: [16411.634797] bnx2x:
> [bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
> Sep 25 12:29:22 debian kernel: [16412.176170] bnx2x:
> [bnx2x_set_aer_mmd:3342(eth2)]Set AER to 0x0
> Sep 25 12:29:23 debian kernel: [16412.408747] bnx2x:
> [bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
> Sep 25 12:29:23 debian kernel: [16412.489861] bnx2x:
> [bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
> Sep 25 12:29:23 debian kernel: [16412.490182] bnx2x:
> [bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
> Sep 25 12:29:23 debian kernel: [16412.490505] bnx2x:
> [bnx2x_get_settings:251(eth2)]ethtool_cmd: cmd 1
> Sep 25 12:29:23 debian kernel: [16412.635849] bnx2x:
> [bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
> Sep 25 12:29:23 debian kernel: [16413.177496] bnx2x:
> [bnx2x_set_aer_mmd:3342(eth2)]Set AER to 0x0
> Sep 25 12:29:24 debian kernel: [16413.411329] bnx2x:
> [bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
>
> JM

After a reboot (with the added if but no netif_msg) :

[  998.244250] bnx2x: [bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
[  998.244251]   supported 0x7460  advertising 0x7460  speed 2500
[  998.244252]   duplex 1  port 3  phy_address 1  transceiver 0
[  998.244252]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[  998.244551] bnx2x: [bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
[  998.244552]   supported 0x7460  advertising 0x7460  speed 8000
[  998.244552]   duplex 1  port 3  phy_address 1  transceiver 0
[  998.244553]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[  998.244851] bnx2x: [bnx2x_get_settings:251(eth2)]ethtool_cmd: cmd 1
[  998.244852]   supported 0x7460  advertising 0x7460  speed 2500
[  998.244852]   duplex 1  port 3  phy_address 1  transceiver 0
[  998.244853]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[  998.246453] bnx2x: [bnx2x_get_settings:251(eth3)]ethtool_cmd: cmd 1
[  998.246454]   supported 0x7460  advertising 0x7460  speed 1000
[  998.246454]   duplex 1  port 3  phy_address 1  transceiver 0
[  998.246455]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[  998.255995] bnx2x: [bnx2x_set_aer_mmd:3342(eth3)]Set AER to 0x2
[  998.643647] bnx2x: [bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
[  998.723597] bnx2x: [bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
[  998.735816] bnx2x: [bnx2x_set_aer_mmd:3342(eth2)]Set AER to 0x0
[  999.255050] bnx2x: [bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
[  999.255051]   supported 0x7460  advertising 0x7460  speed 2500
[  999.255052]   duplex 1  port 3  phy_address 1  transceiver 0
[  999.255052]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[  999.255356] bnx2x: [bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
[  999.255356]   supported 0x7460  advertising 0x7460  speed 8000
[  999.255357]   duplex 1  port 3  phy_address 1  transceiver 0
[  999.255358]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[  999.255651] bnx2x: [bnx2x_get_settings:251(eth2)]ethtool_cmd: cmd 1
[  999.255652]   supported 0x7460  advertising 0x7460  speed 2500
[  999.255653]   duplex 1  port 3  phy_address 1  transceiver 0
[  999.255653]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[  999.255943] bnx2x: [bnx2x_get_settings:251(eth3)]ethtool_cmd: cmd 1
[  999.255944]   supported 0x7460  advertising 0x7460  speed 1000
[  999.255944]   duplex 1  port 3  phy_address 1  transceiver 0
[  999.255945]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[  999.257380] bnx2x: [bnx2x_set_aer_mmd:3342(eth3)]Set AER to 0x2
[  999.644969] bnx2x: [bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
[  999.724909] bnx2x: [bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
[  999.737130] bnx2x: [bnx2x_set_aer_mmd:3342(eth2)]Set AER to 0x0
[ 1000.258622] bnx2x: [bnx2x_set_aer_mmd:3342(eth3)]Set AER to 0x2
[ 1000.263951] bnx2x: [bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
[ 1000.263952]   supported 0x7460  advertising 0x7460  speed 2500
[ 1000.263952]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1000.263953]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1000.264240] bnx2x: [bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
[ 1000.264241]   supported 0x7460  advertising 0x7460  speed 8000
[ 1000.264241]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1000.264242]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1000.264525] bnx2x: [bnx2x_get_settings:251(eth2)]ethtool_cmd: cmd 1
[ 1000.264525]   supported 0x7460  advertising 0x7460  speed 2500
[ 1000.264526]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1000.264527]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1000.264815] bnx2x: [bnx2x_get_settings:251(eth3)]ethtool_cmd: cmd 1
[ 1000.264816]   supported 0x7460  advertising 0x7460  speed 1000
[ 1000.264816]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1000.264817]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1000.646283] bnx2x: [bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
[ 1000.726224] bnx2x: [bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
[ 1000.738445] bnx2x: [bnx2x_set_aer_mmd:3342(eth2)]Set AER to 0x0
[ 1001.260013] bnx2x: [bnx2x_set_aer_mmd:3342(eth3)]Set AER to 0x2
[ 1001.272929] bnx2x: [bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
[ 1001.272930]   supported 0x7460  advertising 0x7460  speed 2500
[ 1001.272931]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1001.272931]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1001.273221] bnx2x: [bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
[ 1001.273222]   supported 0x7460  advertising 0x7460  speed 8000
[ 1001.273222]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1001.273223]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1001.273503] bnx2x: [bnx2x_get_settings:251(eth2)]ethtool_cmd: cmd 1
[ 1001.273504]   supported 0x7460  advertising 0x7460  speed 2500
[ 1001.273505]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1001.273505]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1001.273790] bnx2x: [bnx2x_get_settings:251(eth3)]ethtool_cmd: cmd 1
[ 1001.273790]   supported 0x7460  advertising 0x7460  speed 1000
[ 1001.273791]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1001.273791]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1001.647598] bnx2x: [bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
[ 1001.727540] bnx2x: [bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
[ 1001.739762] bnx2x: [bnx2x_set_aer_mmd:3342(eth2)]Set AER to 0x0
[ 1002.261261] bnx2x: [bnx2x_set_aer_mmd:3342(eth3)]Set AER to 0x2
[ 1002.281715] bnx2x: [bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
[ 1002.281715]   supported 0x7460  advertising 0x7460  speed 2500
[ 1002.281716]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1002.281717]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1002.282002] bnx2x: [bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
[ 1002.282003]   supported 0x7460  advertising 0x7460  speed 8000
[ 1002.282003]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1002.282004]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1002.282294] bnx2x: [bnx2x_get_settings:251(eth2)]ethtool_cmd: cmd 1
[ 1002.282295]   supported 0x7460  advertising 0x7460  speed 2500
[ 1002.282296]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1002.282296]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1002.282583] bnx2x: [bnx2x_get_settings:251(eth3)]ethtool_cmd: cmd 1
[ 1002.282584]   supported 0x7460  advertising 0x7460  speed 1000
[ 1002.282584]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1002.282585]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1002.648914] bnx2x: [bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
[ 1002.728852] bnx2x: [bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
[ 1002.741076] bnx2x: [bnx2x_set_aer_mmd:3342(eth2)]Set AER to 0x0
[ 1003.262650] bnx2x: [bnx2x_set_aer_mmd:3342(eth3)]Set AER to 0x2
[ 1003.290582] bnx2x: [bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
[ 1003.290583]   supported 0x7460  advertising 0x7460  speed 2500
[ 1003.290584]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1003.290584]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1003.290886] bnx2x: [bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
[ 1003.290887]   supported 0x7460  advertising 0x7460  speed 8000
[ 1003.290887]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1003.290888]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1003.291188] bnx2x: [bnx2x_get_settings:251(eth2)]ethtool_cmd: cmd 1
[ 1003.291188]   supported 0x7460  advertising 0x7460  speed 2500
[ 1003.291189]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1003.291190]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1003.291493] bnx2x: [bnx2x_get_settings:251(eth3)]ethtool_cmd: cmd 1
[ 1003.291494]   supported 0x7460  advertising 0x7460  speed 1000
[ 1003.291494]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1003.291495]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1003.650229] bnx2x: [bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
[ 1003.730167] bnx2x: [bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
[ 1003.742391] bnx2x: [bnx2x_set_aer_mmd:3342(eth2)]Set AER to 0x0
[ 1004.263895] bnx2x: [bnx2x_set_aer_mmd:3342(eth3)]Set AER to 0x2
[ 1004.299670] bnx2x: [bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
[ 1004.299671]   supported 0x7460  advertising 0x7460  speed 2500
[ 1004.299672]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1004.299673]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1004.299986] bnx2x: [bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
[ 1004.299987]   supported 0x7460  advertising 0x7460  speed 8000
[ 1004.299987]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1004.299988]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1004.300293] bnx2x: [bnx2x_get_settings:251(eth2)]ethtool_cmd: cmd 1
[ 1004.300293]   supported 0x7460  advertising 0x7460  speed 2500
[ 1004.300294]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1004.300295]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1004.300600] bnx2x: [bnx2x_get_settings:251(eth3)]ethtool_cmd: cmd 1
[ 1004.300600]   supported 0x7460  advertising 0x7460  speed 1000
[ 1004.300601]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1004.300601]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1004.651587] bnx2x: [bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
[ 1004.731481] bnx2x: [bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
[ 1004.743705] bnx2x: [bnx2x_set_aer_mmd:3342(eth2)]Set AER to 0x0
[ 1005.265285] bnx2x: [bnx2x_set_aer_mmd:3342(eth3)]Set AER to 0x2
[ 1005.308537] bnx2x: [bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
[ 1005.308538]   supported 0x7460  advertising 0x7460  speed 2500
[ 1005.308538]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1005.308539]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1005.308840] bnx2x: [bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
[ 1005.308841]   supported 0x7460  advertising 0x7460  speed 8000
[ 1005.308841]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1005.308842]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1005.309147] bnx2x: [bnx2x_get_settings:251(eth2)]ethtool_cmd: cmd 1
[ 1005.309147]   supported 0x7460  advertising 0x7460  speed 2500
[ 1005.309148]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1005.309149]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1005.309448] bnx2x: [bnx2x_get_settings:251(eth3)]ethtool_cmd: cmd 1
[ 1005.309448]   supported 0x7460  advertising 0x7460  speed 1000
[ 1005.309449]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1005.309450]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1005.652906] bnx2x: [bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
[ 1005.732798] bnx2x: [bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
[ 1005.745020] bnx2x: [bnx2x_set_aer_mmd:3342(eth2)]Set AER to 0x0
[ 1006.266543] bnx2x: [bnx2x_set_aer_mmd:3342(eth3)]Set AER to 0x2
[ 1006.317428] bnx2x: [bnx2x_get_settings:251(eth0)]ethtool_cmd: cmd 1
[ 1006.317429]   supported 0x7460  advertising 0x7460  speed 2500
[ 1006.317430]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1006.317431]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1006.317731] bnx2x: [bnx2x_get_settings:251(eth1)]ethtool_cmd: cmd 1
[ 1006.317732]   supported 0x7460  advertising 0x7460  speed 8000
[ 1006.317733]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1006.317733]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1006.318031] bnx2x: [bnx2x_get_settings:251(eth2)]ethtool_cmd: cmd 1
[ 1006.318031]   supported 0x7460  advertising 0x7460  speed 2500
[ 1006.318032]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1006.318033]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1006.318329] bnx2x: [bnx2x_get_settings:251(eth3)]ethtool_cmd: cmd 1
[ 1006.318330]   supported 0x7460  advertising 0x7460  speed 1000
[ 1006.318331]   duplex 1  port 3  phy_address 1  transceiver 0
[ 1006.318331]   autoneg 1  maxtxpkt 0  maxrxpkt 0
[ 1006.654172] bnx2x: [bnx2x_set_aer_mmd:3342(eth1)]Set AER to 0x2
[ 1006.734109] bnx2x: [bnx2x_set_aer_mmd:3342(eth0)]Set AER to 0x0
[ 1006.746331] bnx2x: [bnx2x_set_aer_mmd:3342(eth2)]Set AER to 0x0
