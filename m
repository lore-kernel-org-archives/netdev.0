From: "Rafael J. Wysocki" <rafael@kernel.org>
Subject: Re: [PATCH 2/2] net, thunder, bgx: Add support for ACPI binding.
Date: Sat, 8 Aug 2015 02:32:42 +0200
Message-ID: <CAJZ5v0hG8xUX9k7QD+vTR90_V+Rrvv3LqxLF966YCRk192zrzQ@mail.gmail.com>
References: <1438907590-29649-1-git-send-email-ddaney.cavm@gmail.com>
	<1438907590-29649-3-git-send-email-ddaney.cavm@gmail.com>
	<20150807145414.GA5468@xora-haswell.xora.org.uk>
	<55C4F597.50103@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Graeme Gregory <gg@slimlogic.co.uk>,
	David Daney <ddaney.cavm@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-mips@linux-mips.org, Robert Richter <rrichter@cavium.com>,
	Tomasz Nowicki <tomasz.nowicki@linaro.org>,
	Sunil Goutham <sgoutham@cavium.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
	David Daney <david.daney@cavium.com>
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <55C4F597.50103@caviumnetworks.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Fri, Aug 7, 2015 at 8:14 PM, David Daney <ddaney@caviumnetworks.com> wrote:
> On 08/07/2015 07:54 AM, Graeme Gregory wrote:
>>
>> On Thu, Aug 06, 2015 at 05:33:10PM -0700, David Daney wrote:
>>>
>>> From: David Daney <david.daney@cavium.com>
>>>
>>> Find out which PHYs belong to which BGX instance in the ACPI way.
>>>
>>> Set the MAC address of the device as provided by ACPI tables. This is
>>> similar to the implementation for devicetree in
>>> of_get_mac_address(). The table is searched for the device property
>>> entries "mac-address", "local-mac-address" and "address" in that
>>> order. The address is provided in a u64 variable and must contain a
>>> valid 6 bytes-len mac addr.
>>>
>>> Based on code from: Narinder Dhillon <ndhillon@cavium.com>
>>>                      Tomasz Nowicki <tomasz.nowicki@linaro.org>
>>>                      Robert Richter <rrichter@cavium.com>
>>>
>>> Signed-off-by: Tomasz Nowicki <tomasz.nowicki@linaro.org>
>>> Signed-off-by: Robert Richter <rrichter@cavium.com>
>>> Signed-off-by: David Daney <david.daney@cavium.com>
>>> ---
>>>   drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 137
>>> +++++++++++++++++++++-
>>>   1 file changed, 135 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
>>> b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
>>> index 615b2af..2056583 100644
>>> --- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
>>> +++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
>
> [...]
>>>
>>> +
>>> +static int acpi_get_mac_address(struct acpi_device *adev, u8 *dst)
>>> +{
>>> +       const union acpi_object *prop;
>>> +       u64 mac_val;
>>> +       u8 mac[ETH_ALEN];
>>> +       int i, j;
>>> +       int ret;
>>> +
>>> +       for (i = 0; i < ARRAY_SIZE(addr_propnames); i++) {
>>> +               ret = acpi_dev_get_property(adev, addr_propnames[i],
>>> +                                           ACPI_TYPE_INTEGER, &prop);
>>
>>
>> Shouldn't this be trying to use device_property_read_* API and making
>> the DT/ACPI path the same where possible?
>>
>
> Ideally, something like you suggest would be possible.  However, there are a
> couple of problems trying to do it in the kernel as it exists today:
>
> 1) There is no 'struct device *' here, so device_property_read_* is not
> applicable.
>
> 2) There is no standard ACPI binding for MAC addresses, so it is impossible
> to create a hypothetical fw_get_mac_address(), which would be analogous to
> of_get_mac_address().
>
> Other e-mail threads have suggested that the path to an elegant solution is
> to inter-mix a bunch of calls to acpi_dev_get_property*() and
> fwnode_property_read*() as to use these more generic fwnode_property_read*()
> functions whereever possible.  I rejected this approach as it seems cleaner
> to me to consistently use a single set of APIs.

Actually, that wasn't my intention.

I wanted to say that once you'd got an ACPI device pointer (struct
acpi_device), you could easly convert it to a struct fwnode_handle
pointer and operate that going forward when accessing properties.
That at least would help with the properties that do not differ
between DT and ACPI.

Thanks,
Rafael
