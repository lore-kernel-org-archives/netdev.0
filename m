From: "Fujinaka, Todd" <todd.fujinaka@intel.com>
Subject: RE: [E1000-devel] 82571EB: Detected Hardware Unit Hang
Date: Mon, 26 Nov 2012 16:23:40 +0000
Message-ID: <9B4A1B1917080E46B64F07F2989DADD62F2D62D6@ORSMSX102.amr.corp.intel.com>
References: <509B5038.8090304@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA89133487884@ORSMSX102.amr.corp.intel.com>
	<50A30656.6090508@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA8913348B105@ORSMSX102.amr.corp.intel.com>
	<50A43828.6000702@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA8913349A0B4@ORSMSX102.amr.corp.intel.com>
	<50A9C5CC.1030300@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA8913349EB41@ORSMSX102.amr.corp.intel.com>
 <50AB8471.7080607@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Mary Mcgrath <mary.mcgrath@oracle.com>
To: Joe Jin <joe.jin@oracle.com>,
	"Dave, Tushar N" <tushar.n.dave@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50AB8471.7080607@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Nov 2012, Joe Jin wrote:

> On 11/20/12 16:59, Dave, Tushar N wrote:
>> Have you power off the system completely after modifying eeprom? If not please do so.
>
> Hi Tushar,
>
> Seems not works for me, would you please help to check what is wrong of my operations?

...

> # lspci -s 0000:52:00.1 -vvv
> 52:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet Controller (rev 06)
> <--snip-->
>       Capabilities: [e0] Express (v1) Endpoint, MSI 00
>               DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
                ^^^^^^^^^^^^^^^^^^^^
>                       ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
>               DevCtl: Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
>                       RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
>                       MaxPayload 128 bytes, MaxReadReq 4096 bytes
>           ^^^^^^^^^^^^^^^^^^^^^
>
 <--snip-->

If you look at the previous section, DevCap, you'll see that it's
correctly advertising 256 bytes but the system is negotiating 128 for
the link to the Ethernet controller. Things on the "other" side of the
link are controlled outside of the e1000 driver.

Tushar's first suggestion was to check the PCIe payload settings in the
entire chain. Have you done that? Mismatches will cause hangs.

Todd Fujinaka
Technical Marketing Engineer
LAN Access Division (LAD)
Intel Corporation
todd.fujinaka@intel.com
(503) 712-4565
