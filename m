From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 1/4] ixgbe: sparc: rename the ARCH_WANT_RELAX_ORDER
 to IXGBE_ALLOW_RELAXED_ORDER
Date: Wed, 26 Apr 2017 09:18:33 -0700
Message-ID: <CAKgT0Uc4L=GgYbpO-Fm9OfN+_fLypbDP1c+X4T_ta90ecQiyGQ@mail.gmail.com>
References: <20170401.112603.1991545644693496714.davem@davemloft.net>
 <42428725-89f1-1508-4e3d-723e087b3bbb@huawei.com> <EE11001F9E5DDD47B7634E2F8A612F2E205199C0@FRAEML521-MBX.china.huawei.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFFD3C52@AcuExch.aculab.com>
 <DB5PR05MB138288172B04713EB0C1DB55D3190@DB5PR05MB1382.eurprd05.prod.outlook.com>
 <a2239141-a185-1bb8-0abd-7a05b9fde015@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Ancel <amira@mellanox.com>,
        David Laight <David.Laight@aculab.com>,
        Gabriele Paoloni <gabriele.paoloni@huawei.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Robin Murphy <robin.murphy@arm.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        LinuxArm <linuxarm@huawei.com>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <a2239141-a185-1bb8-0abd-7a05b9fde015@huawei.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 26, 2017 at 2:26 AM, Ding Tianhong <dingtianhong@huawei.com> wrote:
> Hi Amir:
>
> It is really glad to hear that the mlx5 will support RO mode this year, if so, do you agree that enable it dynamic by ethtool -s xxx,
> we have try it several month ago but there was only one drivers would use it at that time so the maintainer against it, it mlx5 would support RO,
> we could try to restart this solution, what do you think about it. :)
>
> Thanks
> Ding

Hi Ding,

Enabing relaxed ordering really doesn't have any place in ethtool. It
is a PCIe attribute that you are essentially wanting to enable.

It might be worth while to take a look at updating the PCIe code path
to handle this. Really what we should probably do is guarantee that
the architectures that need relaxed ordering are setting it in the
PCIe Device Control register and that the ones that don't are clearing
the bit. It's possible that this is already occurring, but I don't
know the state of handling those bits is in the kernel. Once we can
guarantee that we could use that to have the drivers determine their
behavior in regards to relaxed ordering. For example in the case of
igb/ixgbe we could probably change the behavior so that it will bey
default try to use relaxed ordering but if it is not enabled in PCIe
Device Control register the hardware should not request to use it. It
would simplify things in the drivers and allow for each architecture
to control things as needed in their PCIe code.

- Alex
