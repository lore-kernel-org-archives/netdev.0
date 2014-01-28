From: Alexey Charkov <alchark@gmail.com>
Subject: Re: [PATCH 3/3] net: via-rhine: add OF bus binding
Date: Tue, 28 Jan 2014 22:31:20 +0400
Message-ID: <CABjd4Yx5HtbGjo_ZsOJ5SvqFQZey1fv5K36PD=D9fUUn0SanVQ@mail.gmail.com>
References: <1385227995-3956-1-git-send-email-alchark@gmail.com>
	<1390823503-24087-1-git-send-email-alchark@gmail.com>
	<1390823503-24087-4-git-send-email-alchark@gmail.com>
	<1390834654.2735.148.camel@deadeye.wl.decadent.org.uk>
	<CABjd4Yz2Kfed_qBfSAEXoAcVxfsmhTBA-83YJ9_iSwPZ+r1qYQ@mail.gmail.com>
	<1390866011.4405.2.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Tony Prisk <linux@prisktech.co.nz>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Roger Luethi <rl@hellgate.ch>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390866011.4405.2.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014/1/28 Ben Hutchings <ben@decadent.org.uk>:
> On Mon, 2014-01-27 at 19:34 +0400, Alexey Charkov wrote:
>> 2014/1/27 Ben Hutchings <ben@decadent.org.uk>:
>> > On Mon, 2014-01-27 at 15:51 +0400, Alexey Charkov wrote:
>> >> This should make the driver usable with VIA/WonderMedia ARM-based
>> >> Systems-on-Chip integrated Rhine III adapters. Note that these
>> >> are always in MMIO mode, and don't have any known EEPROM.
>> > [...]
>> >> --- a/drivers/net/ethernet/via/Kconfig
>> >> +++ b/drivers/net/ethernet/via/Kconfig
>> >> @@ -19,7 +19,7 @@ if NET_VENDOR_VIA
>> >>
>> >>  config VIA_RHINE
>> >>         tristate "VIA Rhine support"
>> >> -       depends on PCI
>> >> +       depends on (PCI || USE_OF)
>> >>         select CRC32
>> >>         select MII
>> >>         ---help---
>> >
>> > This seems like the right thing to do, but it means you need to add
>> > #ifdef CONFIG_PCI and #ifdef CONFIG_USE_OF around the driver structures
>> > and related functions.
>>
>> Frankly, I would like to avoid that if possible (as pointed out in the
>> cover email), as I believe we would get a cleaner driver without
>> #ifdef. This is also the way it was done in via-velocity, and it works
>> just fine.
>
> OK, I'm surprised that all the PCI functions have dummy definitions.
>
>> > You should compile-test in configurations that have just one of those
>> > dependencies enabled.
>>
>> This has been compile-tested and runtime-tested in OF-only
>> configuration on WM8950, and Roger also tested it in PCI-only
>> configuration, so it seems to work fine.
> [...]
>
> Good, then I have no objection.

Thanks Ben! Would it be fine to add your Reviewed-by at the next
iteration, once I fix indentation of function arguments and
dev_is_pci()?

Thanks,
Alexey
