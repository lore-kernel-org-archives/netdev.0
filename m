From: Peter Rosin <peda@axentia.se>
Subject: Re: [PATCH 04/10] i2c: i2c-sam: Add device tree bindings
Date: Tue, 11 Oct 2016 09:13:42 +0200
Message-ID: <1f5afc57-6b12-4096-587f-5a0f4ebee673@axentia.se>
References: <1475853518-22264-1-git-send-email-pantelis.antoniou@konsulko.com>
 <1475853518-22264-5-git-send-email-pantelis.antoniou@konsulko.com>
 <20161010195458.GA20134@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, Alexandre Courbot <gnurou@gmail.com>,
 devicetree@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
 linux-watchdog@vger.kernel.org, Georgi Vlaev <gvlaev@juniper.net>,
 Wolfram Sang <wsa@the-dreams.de>, Maryam Seraj <mseraj@juniper.net>,
 Frank Rowand <frowand.list@gmail.com>,
 Linus Walleij <linus.walleij@linaro.org>, linux-kernel@vger.kernel.org,
 linux-gpio@vger.kernel.org, Wim Van Sebroeck <wim@iguana.be>,
 linux-mtd@lists.infradead.org, Debjit Ghosh <dghosh@juniper.net>,
 netdev@vger.kernel.org, Brian Norris <computersforpeace@gmail.com>,
 Lee Jones <lee.jones@linaro.org>, David Woodhouse <dwmw2@infradead.org>,
 Guenter Roeck <linux@roeck-us.net>, linux-i2c@vger.kernel.org
To: Rob Herring <robh@kernel.org>, Pantelis Antoniou
 <pantelis.antoniou@konsulko.com>
Return-path: <linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org>
In-Reply-To: <20161010195458.GA20134@rob-hp-laptop>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mtd/>
List-Post: <mailto:linux-mtd@lists.infradead.org>
List-Help: <mailto:linux-mtd-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=subscribe>
Sender: "linux-mtd" <linux-mtd-bounces@lists.infradead.org>
Errors-To: linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 2016-10-10 21:54, Rob Herring wrote:
> On Fri, Oct 07, 2016 at 06:18:32PM +0300, Pantelis Antoniou wrote:
>> From: Georgi Vlaev <gvlaev@juniper.net>
>>
>> Add binding document for the i2c driver of SAM FPGA.
>>
>> Signed-off-by: Georgi Vlaev <gvlaev@juniper.net>
>> [Ported from Juniper kernel]
>> Signed-off-by: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
>> ---
>>  .../devicetree/bindings/i2c/i2c-sam-mux.txt        | 20 ++++++++++
>>  Documentation/devicetree/bindings/i2c/i2c-sam.txt  | 44 ++++++++++++++++++++++
>>  2 files changed, 64 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/i2c/i2c-sam-mux.txt
>>  create mode 100644 Documentation/devicetree/bindings/i2c/i2c-sam.txt
>>
>> diff --git a/Documentation/devicetree/bindings/i2c/i2c-sam-mux.txt b/Documentation/devicetree/bindings/i2c/i2c-sam-mux.txt
>> new file mode 100644
>> index 0000000..10ddffa
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/i2c/i2c-sam-mux.txt
>> @@ -0,0 +1,20 @@
>> +Juniper's SAM FPGA I2C accelerator mux
>> +
>> +The SAM FPGA I2C mux is present only on Juniper SAM FPGA PTX series
>> +of routers.
>> +
>> +The definition of the i2c sam bus is located in the i2c-sam.txt document.
>> +
>> +Required properties:
>> +- compatible: should be "jnx,i2c-sam-mux".
>> +- reg: master number and mux number.
> 
> This is not how i2c muxes are done.
> 
>> +
>> +Optional properties:
>> +- speed: If present must be either 100000 or 400000. No other values supported.
>> +
>> +Examples:
>> +
>> +pe1i2c: i2c-sam-mux@1,0 {
> 
> i2c-mux@...
> 
>> +	compatible = "jnx,i2c-sam-mux";
>> +	reg = <1 0>;
>> +};
>> diff --git a/Documentation/devicetree/bindings/i2c/i2c-sam.txt b/Documentation/devicetree/bindings/i2c/i2c-sam.txt
>> new file mode 100644
>> index 0000000..4830b48
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/i2c/i2c-sam.txt
>> @@ -0,0 +1,44 @@
>> +Juniper's SAM FPGA I2C accelerator
>> +
>> +The SAM FPGA accelerator is used to connect the large number of
>> +I2C muxes that are present on Juniper PTX series of routers.
>> +While it's an i2c bus, no other devices are located besides
>> +i2c-sam-mux devices.
>> +
>> +The definition of the i2c sam mux is located in the i2c-sam-mux.txt document.
>> +
>> +Required properties:
>> +- compatible: should be "jnx,i2c-sam".
>> +- #address-cells: should be 2.
>> +- #size-cells: should be 0.
>> +- mux-channels: number of mux channels present
> 
> What is this needed for?
> 
>> +
>> +Optional properties:
>> +- reg: offset and length of the register set for the device are optional since
>> +  typically the register range is provided by the parent SAM MFD device.
>> +- master-offset: Offset of where the master register memory starts.
>> +  Default value is 0x8000.
> 
> Make this required.
> 
>> +- reverse-fill: Fill the start entries of transactions in reverse order
> 
> Needs a better explanation.
> 
>> +- priority-tables: Use the pre-programmed priority tables in the FPGA
> 
> What does not present mean?
> 
>> +- i2c-options: list of options to be written to the option field in the
>> +  FPGA controlling things like SCL push-pull drives, hold-times, etc.
> 
>> +- bus-range: start of bus master range and number of masters.
> 
> Needs a better explanation.
> 
>> +
>> +Examples:
>> +
>> +i2c-sam {
>> +	compatible = "jnx,i2c-sam";
>> +	mux-channels = <2>;
>> +	#size-cells = <0>;
>> +	#address-cells = <2>;
>> +
>> +	/* PE0 */ pe0i2c: i2c-sam-mux@0,0 {
> 
> i2c-mux@...

Hmm, I actually think i2c@... is the usual naming for i2c-mux children.

Cheers,
Peter

>> +		compatible = "jnx,i2c-sam-mux";
>> +		reg = <0 0>;
>> +	};
>> +
>> +	/* PE1 */ pe1i2c: i2c-sam-mux@1,0 {
>> +		compatible = "jnx,i2c-sam-mux";
>> +		reg = <1 0>;
>> +	};
>> +};
>> -- 
>> 1.9.1
>>


______________________________________________________
Linux MTD discussion mailing list
http://lists.infradead.org/mailman/listinfo/linux-mtd/
