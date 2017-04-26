From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 1/4] ixgbe: sparc: rename the
 ARCH_WANT_RELAX_ORDER to IXGBE_ALLOW_RELAXED_ORDER
Date: Wed, 26 Apr 2017 17:26:37 +0800
Message-ID: <a2239141-a185-1bb8-0abd-7a05b9fde015@huawei.com>
References: <20170401.112603.1991545644693496714.davem@davemloft.net>
 <42428725-89f1-1508-4e3d-723e087b3bbb@huawei.com>
 <EE11001F9E5DDD47B7634E2F8A612F2E205199C0@FRAEML521-MBX.china.huawei.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFFD3C52@AcuExch.aculab.com>
 <DB5PR05MB138288172B04713EB0C1DB55D3190@DB5PR05MB1382.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>,
 LinuxArm <linuxarm@huawei.com>,
 "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
 "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Robin Murphy <robin.murphy@arm.com>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Amir Ancel <amira@mellanox.com>, David Laight <David.Laight@ACULAB.COM>,
 "'Gabriele Paoloni'" <gabriele.paoloni@huawei.com>, "davem@davemloft.net"
 <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <DB5PR05MB138288172B04713EB0C1DB55D3190@DB5PR05MB1382.eurprd05.prod.outlook.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Amir:

It is really glad to hear that the mlx5 will support RO mode this year, if so, do you agree that enable it dynamic by ethtool -s xxx,
we have try it several month ago but there was only one drivers would use it at that time so the maintainer against it, it mlx5 would support RO,
we could try to restart this solution, what do you think about it. :)

Thanks
Ding

On 2017/4/19 4:17, Amir Ancel wrote:
> Hi,
> 
> mlx5 driver is planned to have RO support this year.
> 
> I believe drivers should be able to query whether the arch support it or not and enable it in the network adapter accordingly.
> 
>  
> 
> -Amir
> 
> ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
> *From:* netdev-owner@vger.kernel.org <netdev-owner@vger.kernel.org> on behalf of David Laight <David.Laight@ACULAB.COM>
> *Sent:* Tuesday, April 18, 2017 4:25:44 PM
> *To:* 'Gabriele Paoloni'; davem@davemloft.net
> *Cc:* Catalin Marinas; Will Deacon; Mark Rutland; Robin Murphy; jeffrey.t.kirsher@intel.com; alexander.duyck@gmail.com; linux-arm-kernel@lists.infradead.org; netdev@vger.kernel.org; Dingtianhong; Linuxarm
> *Subject:* RE: Re: [PATCH net-next 1/4] ixgbe: sparc: rename the ARCH_WANT_RELAX_ORDER to IXGBE_ALLOW_RELAXED_ORDER
>  
> From: Gabriele Paoloni
>> Sent: 13 April 2017 10:11
>> > > Till now only the Intel ixgbe could support enable
>> > > Relaxed ordering in the drivers for special architecture,
>> > > but the ARCH_WANT_RELAX_ORDER is looks like a general name
>> > > for all arch, so rename to a specific name for intel
>> > > card looks more appropriate.
>> > >
>> > > Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> >
>> > This is not a driver specific facility.
>> >
>> > Any driver can test this symbol and act accordingly.
>> >
>> > Just because IXGBE is the first and only user, doesn't mean
>> > the facility is driver specific.
>> 
>> 
>> Please correct me if I am wrong but my understanding is that the standard
>> way to enable/disable relaxed ordering is to set/clear bit 4 of the Device
>> Control Register (PCI_EXP_DEVCTL_RELAX_EN 0x0010 /* Enable relaxed
>> ordering */).
>> Now I have looked up for all drivers either enabling or disabling relaxed
>> ordering and none of them seems to need a symbol to decide whether to
>> enable it or not.
>> Also it seems to me enabling/disabling relaxed ordering is never bound to the
>> host architecture.
>> 
>> So why this should be (or it is expected to be) a generic symbol?
>> Wouldn't it be more correct to have this as a driver specific symbol now and
>> move it to a generic one later once we have other drivers requiring it?
> 
> 'Relaxed ordering' is a bit in the TLP header.
> A device (like the ixgbe hardware) can set it for some transactions and
> still have the transactions 'ordered enough' for the driver to work.
> (If all transactions have 'relaxed ordering' set then I suspect it is
> almost impossible to write a working driver.)
> The host side could (probably does) have a bit to enable 'relaxed ordering',
> it could also enforce stronger ordering than required by the PCIe spec
> (eg keeping reads in order).
> 
> Clearly, on some sparc64 systems, ixgbe needs to use 'relaxed ordering'.
> To me this requires two separate bits be enabled:
> 1) to the ixgbe driver to generate the 'relaxed' TLP.
> 2) to the host to actually act on them.
> If the ixgbe driver works when both are enabled why have options to
> disable either (except for bug-finding)?
> 
>         David
> 
