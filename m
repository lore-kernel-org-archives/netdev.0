From: Alexey Charkov <alchark@gmail.com>
Subject: Re: [PATCH 3/3] net: via-rhine: add OF bus binding
Date: Tue, 28 Jan 2014 22:27:53 +0400
Message-ID: <CABjd4Yxo0Pp+QtTuXhKBT9KdVhUk12x2L8+FBL_ZWmPYopG2JQ@mail.gmail.com>
References: <1385227995-3956-1-git-send-email-alchark@gmail.com>
	<1390823503-24087-1-git-send-email-alchark@gmail.com>
	<1390823503-24087-4-git-send-email-alchark@gmail.com>
	<CAL_JsqLi0QKeeUkGMKmYZ1ki02mzk=L1gDxTJyXFGiOe_aHiVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Tony Prisk <linux@prisktech.co.nz>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Roger Luethi <rl@hellgate.ch>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Rob Herring <robherring2@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAL_JsqLi0QKeeUkGMKmYZ1ki02mzk=L1gDxTJyXFGiOe_aHiVw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014/1/27 Rob Herring <robherring2@gmail.com>:
> On Mon, Jan 27, 2014 at 5:51 AM, Alexey Charkov <alchark@gmail.com> wrote:
>> This should make the driver usable with VIA/WonderMedia ARM-based
>> Systems-on-Chip integrated Rhine III adapters. Note that these
>> are always in MMIO mode, and don't have any known EEPROM.
>>
>> Signed-off-by: Alexey Charkov <alchark@gmail.com>
>> Signed-off-by: Roger Luethi <rl@hellgate.ch>
>> ---
>>  .../devicetree/bindings/net/via-rhine.txt          |  18 ++
>>  drivers/net/ethernet/via/Kconfig                   |   2 +-
>>  drivers/net/ethernet/via/via-rhine.c               | 293 +++++++++++++--------
>>  3 files changed, 200 insertions(+), 113 deletions(-)
>>  create mode 100644 Documentation/devicetree/bindings/net/via-rhine.txt
>>
>> diff --git a/Documentation/devicetree/bindings/net/via-rhine.txt b/Documentation/devicetree/bindings/net/via-rhine.txt
>> new file mode 100644
>> index 0000000..684dd3a
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/via-rhine.txt
>> @@ -0,0 +1,18 @@
>> +* VIA Rhine 10/100 Network Controller
>> +
>> +Required properties:
>> +- compatible : Should be "via,rhine"
>
> This should be more specific rather than...
>
>> +- reg : Address and length of the io space
>> +- interrupts : Should contain the controller interrupt line
>> +- rhine,revision : Rhine core revision, used to inform the
>> +       driver of quirks and capabilities to expect from
>> +       the device. Mimics the respective PCI attribute.
>
> having this property. The OF match table can then have the quirks set
> based on compatible strings.

Sounds fair. Do you think something like the following would fly?

Required properties:
- compatible : Should be "via,rhine-soc-vt8500" for integrated Rhine
cores found in SoC's such as VIA VT8500, WonderMedia WM8950 and
possibly others. These are listed as 1106:3106 rev. 0x84 on the
virtual PCI bus under vendor-provided kernels.

Thanks,
Alexey
