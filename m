From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: Re: [PATCH 8/9] MIPS: xilfpga: Add DT node for AXI emaclite
Date: Thu, 18 Aug 2016 11:01:08 +0100
Message-ID: <1cfb22d7-1cf0-fe97-5995-ed9671575e57@imgtec.com>
References: <1471269335-58747-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1471269335-58747-9-git-send-email-Zubair.Kakakhel@imgtec.com>
 <20160815151703.GD3353@io.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <monstr@monstr.eu>, <ralf@linux-mips.org>, <tglx@linutronix.de>,
        <marc.zyngier@arm.com>, <linux-mips@linux-mips.org>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20160815151703.GD3353@io.lakedaemon.net>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

Hi,

On 08/15/2016 04:17 PM, Jason Cooper wrote:
> Hi Zubair,
>
> On Mon, Aug 15, 2016 at 02:55:34PM +0100, Zubair Lutfullah Kakakhel wrote:
>> The xilfpga platform has a Xilinx AXI emaclite block.
>>
>> Add the DT node to use it.
>>
>> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
>> ---
>>  arch/mips/boot/dts/xilfpga/nexys4ddr.dts | 27 +++++++++++++++++++++++++++
>>  1 file changed, 27 insertions(+)
>>
>> diff --git a/arch/mips/boot/dts/xilfpga/nexys4ddr.dts b/arch/mips/boot/dts/xilfpga/nexys4ddr.dts
>> index 3658e21..58bc62f 100644
>> --- a/arch/mips/boot/dts/xilfpga/nexys4ddr.dts
>> +++ b/arch/mips/boot/dts/xilfpga/nexys4ddr.dts
>> @@ -42,6 +42,33 @@
>>  		xlnx,tri-default = <0xffffffff>;
>>  	} ;
>>
>> +	axi_ethernetlite: ethernet@10e00000 {
>> +		compatible = "xlnx,xps-ethernetlite-3.00.a";
>
> This one also isn't documented.

These are sort of documented. Although checkpatch probably won't find them.

Xilinx IP blocks follow a generic DT style as documented here.

http://lxr.free-electrons.com/source/Documentation/devicetree/bindings/xilinx.txt

>
>> +		device_type = "network";
>> +		interrupt-parent = <&axi_intc>;
>> +		interrupts = <1>;
>> +		local-mac-address = [08 86 4C 0D F7 09];
>
> I'm pretty sure you don't want this in the mainline dts file.

Oops. Sorry. I'll remove it.

Thanks
ZubairLK

>
> thx,
>
> Jason.
>
>> +		phy-handle = <&phy0>;
>> +		reg = <0x10e00000 0x10000>;
>> +		xlnx,duplex = <0x1>;
>> +		xlnx,include-global-buffers = <0x1>;
>> +		xlnx,include-internal-loopback = <0x0>;
>> +		xlnx,include-mdio = <0x1>;
>> +		xlnx,instance = "axi_ethernetlite_inst";
>> +		xlnx,rx-ping-pong = <0x1>;
>> +		xlnx,s-axi-id-width = <0x1>;
>> +		xlnx,tx-ping-pong = <0x1>;
>> +		xlnx,use-internal = <0x0>;
>> +		mdio {
>> +			#address-cells = <1>;
>> +			#size-cells = <0>;
>> +			phy0: phy@1 {
>> +				device_type = "ethernet-phy";
>> +				reg = <1>;
>> +			};
>> +		};
>> +	};
>> +
>>  	axi_uart16550: serial@10400000 {
>>  		compatible = "ns16550a";
>>  		reg = <0x10400000 0x10000>;
>> --
>> 1.9.1
>>
