From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/6][v3] phylib: Add Clause 45 read/write functions
Date: Mon, 6 Jan 2014 08:55:16 -0800
Message-ID: <CAGVrzcZoMC0hCWNspeViZjNmV39K1OuFT=c855WU_hRe6N6_ew@mail.gmail.com>
References: <1385703912-12800-1-git-send-email-shh.xie@gmail.com> <51bdf0e57ba941bf92b1d969631e440b@BLUPR03MB067.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "shh.xie@gmail.com" <shh.xie@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jg1.han@samsung.com" <jg1.han@samsung.com>,
	"mugunthanvnm@ti.com" <mugunthanvnm@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Shaohui Xie <Shaohui.Xie@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51bdf0e57ba941bf92b1d969631e440b@BLUPR03MB067.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014/1/5 Shaohui Xie <Shaohui.Xie@freescale.com>:
> Hi, All,
>
> I saw the state of this patch sets were set to "Deferred", may I know if there is any plan or request for these patches, or is there a big picture for supporting 10G PHYs?

Can you resubmit the latest version of the patchset, I somehow lost
track of which version is the last one, this would bring a new
patchset in patchwork for David to review.

>
> Best Regards,
> Shaohui Xie
>
>
>> -----Original Message-----
>> From: shh.xie@gmail.com [mailto:shh.xie@gmail.com]
>> Sent: Friday, November 29, 2013 1:45 PM
>> To: davem@davemloft.net; jg1.han@samsung.com; mugunthanvnm@ti.com;
>> f.fainelli@gmail.com; netdev@vger.kernel.org; linux-
>> kernel@vger.kernel.org
>> Cc: Xie Shaohui-B21989
>> Subject: [PATCH 1/6][v3] phylib: Add Clause 45 read/write functions
>>
>> From: Andy Fleming <afleming@freescale.com>
>>
>> Need an extra parameter to read or write Clause 45 PHYs, so need a
>> different API with the extra parameter.
>>
>> Signed-off-by: Andy Fleming <afleming@freescale.com>
>> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
>> ---
>> v3 changes: add C45 check.
>>
>>  include/linux/phy.h | 39 +++++++++++++++++++++++++++++++++++++++
>>  1 file changed, 39 insertions(+)
>>
>> diff --git a/include/linux/phy.h b/include/linux/phy.h index
>> 48a4dc3..0ff2476 100644
>> --- a/include/linux/phy.h
>> +++ b/include/linux/phy.h
>> @@ -498,6 +498,24 @@ static inline int phy_read(struct phy_device *phydev,
>> u32 regnum)  }
>>
>>  /**
>> + * phy_read_mmd - Convenience function for reading a register
>> + * from an MMD on a given PHY.
>> + * @phydev: The phy_device struct
>> + * @devad: The MMD to read from
>> + * @regnum: The register on the MMD to read
>> + *
>> + * Same rules as for phy_read();
>> + */
>> +static inline int phy_read_mmd(struct phy_device *phydev, int devad,
>> +u32 regnum) {
>> +     if (!phydev->is_c45)
>> +             return -EOPNOTSUPP;
>> +
>> +     return mdiobus_read(phydev->bus, phydev->addr,
>> +             MII_ADDR_C45 | (devad << 16) | (regnum & 0xffff)); }
>> +
>> +/**
>>   * phy_write - Convenience function for writing a given PHY register
>>   * @phydev: the phy_device struct
>>   * @regnum: register number to write
>> @@ -533,6 +551,27 @@ static inline bool phy_is_internal(struct phy_device
>> *phydev)
>>       return phydev->is_internal;
>>  }
>>
>> +/**
>> + * phy_write_mmd - Convenience function for writing a register
>> + * on an MMD on a given PHY.
>> + * @phydev: The phy_device struct
>> + * @devad: The MMD to read from
>> + * @regnum: The register on the MMD to read
>> + * @val: value to write to @regnum
>> + *
>> + * Same rules as for phy_write();
>> + */
>> +static inline int phy_write_mmd(struct phy_device *phydev, int devad,
>> +             u32 regnum, u16 val)
>> +{
>> +     if (!phydev->is_c45)
>> +             return -EOPNOTSUPP;
>> +
>> +     regnum = MII_ADDR_C45 | ((devad & 0x1f) << 16) | (regnum & 0xffff);
>> +
>> +     return mdiobus_write(phydev->bus, phydev->addr, regnum, val); }
>> +
>>  struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int
>> phy_id,
>>               bool is_c45, struct phy_c45_device_ids *c45_ids);  struct
>> phy_device *get_phy_device(struct mii_bus *bus, int addr, bool is_c45);
>> --
>> 1.8.4.1
>



-- 
Florian
