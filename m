From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: [PATCH net-next 07/11] net: dsa: Remove support for bypass bridge
 port attributes/vlan set
Date: Wed, 19 Jul 2017 14:53:44 +0300
Message-ID: <07d8159d-d7ab-eac2-0519-b1ce3c8e18c8@mellanox.com>
References: <1500387624-4361-1-git-send-email-arkadis@mellanox.com>
 <1500387624-4361-8-git-send-email-arkadis@mellanox.com>
 <87d18xbq3d.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr50071.outbound.protection.outlook.com ([40.107.5.71]:59264
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752759AbdGSLx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Jul 2017 07:53:56 -0400
In-Reply-To: <87d18xbq3d.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 07/18/2017 08:40 PM, Vivien Didelot wrote:
> Hi Arkadi,
> 
> Arkadi Sharshevsky <arkadis@mellanox.com> writes:
> 
>> The bridge port attributes/vlan for DSA devices should be set only
>> from bridge code. Furthermore, The vlans are synced totally with the
>> bridge so there is no need for special dump support.
>>
>> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
>> ---
>>  drivers/net/dsa/b53/b53_common.c       | 44 --------------------------
>>  drivers/net/dsa/b53/b53_priv.h         |  3 --
>>  drivers/net/dsa/bcm_sf2.c              |  1 -
>>  drivers/net/dsa/dsa_loop.c             | 38 -----------------------
>>  drivers/net/dsa/microchip/ksz_common.c | 41 -------------------------
>>  drivers/net/dsa/mv88e6xxx/chip.c       | 56 ----------------------------------
>>  include/net/dsa.h                      |  4 ---
>>  net/dsa/dsa_priv.h                     |  4 ---
>>  net/dsa/port.c                         | 12 --------
>>  net/dsa/slave.c                        |  6 ----
> 
> Regarding this massive deletion, can you please split it in two patches,
> one deleting first the DSA core usage of .port_vlan_dump, i.e. in:
> 
>     net/dsa/dsa_priv.h
>     net/dsa/port.c
>     net/dsa/slave.c
> 
> Then a second patch which deletes the .port_vlan_dump implementations?
> 
> This may sound useless but it will actually make it easy for us to
> restore the VLAN dump support in drivers once we introduce an
> alternative way to query the hardware.
> 
> 
> Thanks,
> 
>         Vivien
> 

Yeah, no problem. But doesn't it make more sense to remove it first from
the drivers and then from core? If it will be removed from core first it
will leave unused code behind in the driver. Furthermore, it is
symmetric with the code adding. You first add the core implementation
and then only the drivers.
