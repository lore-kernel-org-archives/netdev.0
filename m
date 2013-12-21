From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH V2 1/4] Documentation: Add documentation for APM X-Gene SoC Queue Manager/Traffic Manager DTS binding
Date: Sat, 21 Dec 2013 19:52:20 +0100
Message-ID: <201312211952.20375.arnd@arndb.de>
References: <1387594651-25771-1-git-send-email-rapatel@apm.com> <1387594651-25771-2-git-send-email-rapatel@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	jcm@redhat.com, patches@apm.com, Keyur Chudgar <kchudgar@apm.com>
To: Ravi Patel <rapatel@apm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387594651-25771-2-git-send-email-rapatel@apm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 21 December 2013, Ravi Patel wrote:
>  create mode 100644 Documentation/devicetree/bindings/misc/apm-xgene-qmtm.txt
> 
> diff --git a/Documentation/devicetree/bindings/misc/apm-xgene-qmtm.txt b/Documentation/devicetree/bindings/misc/apm-xgene-qmtm.txt
> new file mode 100644
> index 0000000..c3fcbd2
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/misc/apm-xgene-qmtm.txt
> @@ -0,0 +1,51 @@
> +* APM X-Gene SoC Queue Manager/Traffic Manager nodes
> +
> +QMTM nodes are defined to describe on-chip Queue Managers in APM X-Gene SoC.
> +APM X-Gene SoC Ethernet, PktDMA (XOR Engine), and Security Engine subsystems
> +communicate with a central Queue Manager using messages which include
> +information about the work to be performed and the location of the associated
> +data buffers. There are multiple instances of QMTM. Each QMTM instance has its
> +own node. Its corresponding clock nodes are shown below.
> +
> +Required properties:
> +- compatible		: Shall be "apm,xgene-qmtm-lite" for QMLite instance
> +- reg			: First memory resource shall be the QMTM CSR memory
> +			  resource.
> +			  Second memory resource shall be the QMTM IO-Fabric
> +			  memory resource.
> +- slave-name		: Shall be "CPU_QMTM3" which is receiver for ingress
> +			  work messages for the QMTM. Here receiver is CPU.

What is that string used for? Who decides what strings are valid in the
future? Why does the device even need to know the name of the receiver,
shouldn't that have a separate node?

> +- interrupts		: First interrupt resource shall be the QMTM Error
> +			  interrupt.
> +			  Remaining interrupt resources shall be the Ingress
> +			  work message interrupt mapping for receiver,
> +			  receiving work messages for the QMTM.
> +- clocks		: Reference to the clock entry.
> +
> +Optional properties:
> +- status		: Shall be "ok" if enabled or "disabled" if disabled.
> +			  Default is "ok".
> +
> +Example:
> +		qmlclk: qmlclk {
> +			compatible = "apm,xgene-device-clock";
> +			#clock-cells = <1>;
> +			clock-names = "qmlclk";
> +			status = "ok";
> +			csr-offset = <0x0>;
> +			csr-mask = <0x3>;
> +			enable-offset = <0x8>;
> +			enable-mask = <0x3>;
> +		};

This looks like an invalid node, which makes a bad example. Why do you 
have a "clock-names" entry here but no "clocks"?

> +		qmlite: qmtm@17030000 {
> +			compatible = "apm,xgene-qmtm-lite";
> +			reg = <0x0 0x17030000 0x0 0x10000>,
> +			      <0x0 0x10000000 0x0 0x400000>;
> +			slave-name = "CPU_QMTM3";
> +			interrupts = <0x0 0x40 0x4>,
> +				     <0x0 0x3c 0x4>;
> +			status = "ok";
> +			#clock-cells = <1>;
> +			clocks = <&qmlclk 0>;
> +		};

#clock-cells is neither a required nor an optional property for
"apm,xgene-qmtm-lite" according to the documentation above. Please
make the example match the specification.

	Arnd
