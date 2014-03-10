From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [PATCH v5] can: xilinx CAN controller support.
Date: Mon, 10 Mar 2014 16:22:43 +0100
Message-ID: <1e9389a5-744d-4e6c-8428-f95ea0860239@VA3EHSMHS015.ehs.local>
References: <5254bfec-c6fd-4681-a34d-706d51e60fbb@VA3EHSMHS004.ehs.local> <CAL_JsqL3V7Gmkx5MoAhzwbM8Po6QURUY+g3ytxs+H_u-FLR6SQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Michal Simek <michal.simek@xilinx.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>, <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Rob Herring <robherring2@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAL_JsqL3V7Gmkx5MoAhzwbM8Po6QURUY+g3ytxs+H_u-FLR6SQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/10/2014 04:15 PM, Rob Herring wrote:
> On Tue, Mar 4, 2014 at 7:20 AM, Kedareswara rao Appana
> <appana.durga.rao@xilinx.com> wrote:
>> This patch adds xilinx CAN controller support.
>> This driver supports both ZYNQ CANPS and Soft IP
>> AXI CAN controller.
>>
>> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
>> ---
>> This patch is rebased on the 3.14 rc5 kernel.
>> Changes for v5:
>> - Updated the driver with the review comments.
>> - Remove the check for the tx fifo full interrupt condition
>>   form Tx interrupt routine as we are checking it in the _xmit
>>   routine.
>> - Clearing the txok interrupt in the tx interrupt routine for
>>   every Tx can frame.
>> Changes for v4:
>> - Added check for the tx fifo full interrupt condition in
>>   Tx interrupt routine.
>> - Added be iohelper functions.
>> - Moved the clock enable/disable to probe/remove because of
>>   Added big endian support for AXI CAN controller case(reading
>>   a register during probe for that we need to enable clock).
>> Changes for v3:
>> - Updated the driver with the review comments.
>> - Modified the tranmit logic as per Marc suggestion.
>> - Enabling the clock when the interface is up to reduce the
>>   Power consumption.
>> Changes for v2:
>> - Updated with the review comments.
>> - Removed the unnecessary debug prints.
>> - include tx,rx fifo depths in ZYNQ CANPS case also.
>> ---
>>  .../devicetree/bindings/net/can/xilinx_can.txt     |   45 +
>>  drivers/net/can/Kconfig                            |    7 +
>>  drivers/net/can/Makefile                           |    1 +
>>  drivers/net/can/xilinx_can.c                       | 1195 ++++++++++++++++++++
>>  4 files changed, 1248 insertions(+), 0 deletions(-)
>>  create mode 100644 Documentation/devicetree/bindings/net/can/xilinx_can.txt
>>  create mode 100644 drivers/net/can/xilinx_can.c
>>
>> diff --git a/Documentation/devicetree/bindings/net/can/xilinx_can.txt b/Documentation/devicetree/bindings/net/can/xilinx_can.txt
>> new file mode 100644
>> index 0000000..0e57103
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/can/xilinx_can.txt
>> @@ -0,0 +1,45 @@
>> +Xilinx Axi CAN/Zynq CANPS controller Device Tree Bindings
>> +---------------------------------------------------------
>> +
>> +Required properties:
>> +- compatible           : Should be "xlnx,zynq-can-1.00.a" for Zynq CAN
>> +                         controllers and "xlnx,axi-can-1.00.a" for Axi CAN
>> +                         controllers.
>> +- reg                  : Physical base address and size of the Axi CAN/Zynq
>> +                         CANPS registers map.
>> +- interrupts           : Property with a value describing the interrupt
>> +                         number.
>> +- interrupt-parent     : Must be core interrupt controller
>> +- clock-names          : List of input clock names - "ref_clk", "aper_clk"
>> +                         (See clock bindings for details. Two clocks are
>> +                          required for Zynq CAN. For Axi CAN
>> +                          case it is one(ref_clk)).
>> +- clocks               : Clock phandles (see clock bindings for details).
>> +- tx-fifo-depth                : Can Tx fifo depth.
>> +- rx-fifo-depth                : Can Rx fifo depth.
>> +
>> +
>> +Example:
>> +
>> +For Zynq CANPS Dts file:
>> +       zynq_can_0: zynq-can@e0008000 {
> 
> The preferred node name convention is to use the type of device. There
> is no standard in this case, but I would use just "can@...".
> 
> Otherwise, for the binding:
> 
> Acked-by: Rob Herring <robh@kernel.org>

Thanks Rob for your ACK.

Kedar: You have got more things to change from Marc that's why please change this too.

Thanks,
Michal
