From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [bisected] tg3 broken in 3.18.0?
Date: Tue, 16 Dec 2014 18:02:43 -0200
Message-ID: <54908FE3.7060100@gmail.com>
References: <20141213210251.GA12812@teela.fritz.box> <548EF90A.5070607@gmail.com> <CAA93t1qyZE-9tw8pg1KG6g4iyy0QMW=iass5w=6ZGMTMu+vi_A@mail.gmail.com> <CAErSpo5dqQE7nZ6zf2odgpHBWA3ZpTjhbgQKnY8YxQW+a+298w@mail.gmail.com> <1418750141.4248.3.camel@LTIRV-MCHAN1.corp.ad.broadcom.com> <54907300.9050902@gmail.com> <1418759684.4248.12.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	Rajat Jain <rajatxjain@gmail.com>,
	Nils Holland <nholland@tisys.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Rafael Wysocki <rjw@rjwysocki.net>,
	Prashant Sreedharan <prashant@broadcom.com>
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1418759684.4248.12.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-12-2014 17:54, Michael Chan wrote:
> On Tue, 2014-12-16 at 15:59 -0200, Marcelo Ricardo Leitner wrote:
>> It's a
>> 02:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5722
>> Gigabit Ethernet PCI Express
>> over here
>>
>> I put a WARN_ON(1) after those printks, and this is what I got:
>>
>> [    1.550640] pci 0000:02:00.0: 1st 1 1
>> [    1.550643] pci 0000:02:00.0: crs_timeout: 0
>> [    1.550645] ------------[ cut here ]------------
>> [    1.550651] WARNING: CPU: 6 PID: 364 at drivers/pci/probe.c:1445 pci_bus_read_dev_vendor_id+0x1d4/0x1e0()
>> [    1.550652] Modules linked in: i915(+) raid0 i2c_algo_bit drm_kms_helper drm e1000e(+) tg3(+) ptp pps_core video
>> [    1.550660] CPU: 6 PID: 364 Comm: systemd-udevd Not tainted 3.18.0-rc6+ #8
>> [    1.550661] Hardware name: Dell Inc. OptiPlex 9010/03K80F, BIOS A15 08/12/2013
>> [    1.550662]  0000000000000000 000000004de2d8dc ffff8807eabdf948 ffffffff8173db46
>> [    1.550665]  0000000000000000 0000000000000000 ffff8807eabdf988 ffffffff81094d41
>> [    1.550667]  ffff8807eabdf968 ffff8807f1e27000 0000000000000000 0000000000000000
>> [    1.550669] Call Trace:
>> [    1.550675]  [<ffffffff8173db46>] dump_stack+0x46/0x58
>> [    1.550679]  [<ffffffff81094d41>] warn_slowpath_common+0x81/0xa0
>> [    1.550681]  [<ffffffff81094e5a>] warn_slowpath_null+0x1a/0x20
>> [    1.550683]  [<ffffffff813b2864>] pci_bus_read_dev_vendor_id+0x1d4/0x1e0
>> [    1.550687]  [<ffffffff813b7c3e>] pci_device_is_present+0x2e/0x50
>> [    1.550693]  [<ffffffffa003364f>] tg3_chip_reset+0x2f/0x940 [tg3]
>> [    1.550697]  [<ffffffffa0033f9f>] tg3_halt+0x3f/0x1e0 [tg3]
>> [    1.550701]  [<ffffffffa0044f83>] tg3_init_one+0xb83/0x1a40 [tg3]
>
> So does it work if you use a non-zero crs_timeout?  The driver has
> called tg3_halt() which may affect configuration read responses.  I need
> to check with the hardware team to see if the 5722 will return CRS in
> this scenario.

Sorry, I replied to the thread that you weren't in yet.
It didn't..
http://thread.gmane.org/gmane.linux.network/342566/focus=37932

   Marcelo
