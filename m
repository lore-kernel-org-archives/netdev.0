From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: bnx2x + SFP+ DA/2.6.33.3: Got bad status 0x0 when reading from
 SFP+ EEPROM -> SFP+ module is not initialized
Date: Thu, 20 May 2010 21:41:12 +0200
Message-ID: <4BF59058.6050205@ans.pl>
References: <4BF56CA6.8080306@ans.pl> <1274377770.28702.4.camel@lb-tlvb-eilong.il.broadcom.com> <4BF57ADF.1060203@ans.pl> <1274381113.28702.6.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:34887 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754301Ab0ETTlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 15:41:18 -0400
In-Reply-To: <1274381113.28702.6.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-05-20 20:45, Eilon Greenstein wrote:
> On Thu, 2010-05-20 at 11:09 -0700, Krzysztof Ol=C4=99dzki wrote:
>> On 2010-05-20 19:49, Eilon Greenstein wrote:
>>> On Thu, 2010-05-20 at 10:08 -0700, Krzysztof Ol=C4=99dzki wrote:
>>>> Hello,
>>>>
>>>> I would like to connect a dual port SFP+ NetXtreme II BCM57711
>>>> 10-Gigabit NIC to a HP J9309A ProCurve 4-Port 10GbE SFP+ zl Module
>>>> using a HP ProCurve 10-GbE SFP+ 7m Direct Attach Cable (J9285B).
>>>>
>>>> Unfortuantely, it does not work. :( After connecting the switch an=
d
>>>> the server together and loading the bnx2x module the switch logs:
>>>>
>>>> I 05/20/10 18:32:23 ports: port E4 is Blocked by STP
>>>> I 05/20/10 18:32:23 ports: port E4 is now on-line
>>>>
>>>> Here is the dmesg output from the server:
>>>>
>>>> Broadcom NetXtreme II 5771x 10Gigabit Ethernet Driver bnx2x 1.52.1=
-5 (2009/11/09)
>>>> bnx2x 0000:04:00.0: PCI INT A ->   GSI 38 (level, low) ->   IRQ 38
>>>> bnx2x 0000:04:00.0: setting latency timer to 64
>>>> bnx2x: part number 394D4342-31373735-31314131-473331
>>>> bnx2x: Loading bnx2x-e1h-5.2.7.0.fw
>>>> bnx2x 0000:04:00.0: firmware: requesting bnx2x-e1h-5.2.7.0.fw
>>>> eth4: Broadcom NetXtreme II BCM57711 XGb (A0) PCI-E x8 5GHz (Gen2)=
 found at mem dc000000, IRQ 38, node addr 00:10:18:5f:e4:b4
>>>> bnx2x 0000:04:00.1: PCI INT B ->   GSI 45 (level, low) ->   IRQ 45
>>>> bnx2x 0000:04:00.1: setting latency timer to 64
>>>> bnx2x: part number 394D4342-31373735-31314131-473331
>>>> bnx2x: Loading bnx2x-e1h-5.2.7.0.fw
>>>> bnx2x 0000:04:00.1: firmware: requesting bnx2x-e1h-5.2.7.0.fw
>>>> eth5: Broadcom NetXtreme II BCM57711 XGb (A0) PCI-E x8 5GHz (Gen2)=
 found at mem dd000000, IRQ 45, node addr 00:10:18:5f:e4:b6
>>>> bnx2x 0000:04:00.0: irq 97 for MSI/MSI-X
>>>> bnx2x 0000:04:00.0: irq 98 for MSI/MSI-X
>>>> bnx2x 0000:04:00.0: irq 99 for MSI/MSI-X
>>>> bnx2x 0000:04:00.0: irq 100 for MSI/MSI-X
>>>> bnx2x 0000:04:00.0: irq 101 for MSI/MSI-X
>>>> bnx2x 0000:04:00.0: irq 102 for MSI/MSI-X
>>>> bnx2x: eth4: using MSI-X  IRQs: sp 97  fp[0] 99 ... fp[3] 102
>>>> ADDRCONF(NETDEV_UP): eth4: link is not ready
>>>> bnx2x 0000:04:00.1: irq 103 for MSI/MSI-X
>>>> bnx2x 0000:04:00.1: irq 104 for MSI/MSI-X
>>>> bnx2x 0000:04:00.1: irq 105 for MSI/MSI-X
>>>> bnx2x 0000:04:00.1: irq 106 for MSI/MSI-X
>>>> bnx2x 0000:04:00.1: irq 107 for MSI/MSI-X
>>>> bnx2x 0000:04:00.1: irq 108 for MSI/MSI-X
>>>> bnx2x: eth5: using MSI-X  IRQs: sp 103  fp[0] 105 ... fp[3] 108
>>>> ADDRCONF(NETDEV_UP): eth5: link is not ready
>>>> bnx2x: eth5 NIC Link is Down
>>>> bnx2x: eth5 NIC Link is Down
>>>>
>>>> Loading the driver with debug mode enabled (modprobe bnx2x debug=3D=
0x20004) I got:
>>> Thank you for this debug information! You saved one email round tri=
p :)
>>
>> Hehe, thanks.
>>
>>> However, I still need some more information about the FW version an=
d
>>> nvram settings. Can you please send me the output of ethtool -i
>>
>> # ethtool -i eth5
>> driver: bnx2x
>> version: 1.52.1-5
>> firmware-version: BC:5.0.13 PHY:0aa0:0406
>> bus-info: 0000:04:00.1
>>
>>> and ethtool -e? Since ethtool -e is quite long, it is best to send
>>> it as an attached file.
>>
>> Attached.
>
> Almost everything seems to be in order. Almost - since you don't get
> link... I don't think I have tried using this kind of Direct Attach
> Cable - so maybe it just needs some more time. Let's see if the
> following makes any difference (other than delay the failure for anot=
her
> 2.7 seconds):
>
> diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
> index ff70be8..bcee38c 100644
> --- a/drivers/net/bnx2x_link.c
> +++ b/drivers/net/bnx2x_link.c
> @@ -3113,7 +3113,7 @@ static u8
> bnx2x_wait_for_sfp_module_initialized(struct link_params *params)
>          u16 timeout;
>          /* Initialization time after hot-plug may take up to 300ms f=
or
> some
>          phys type ( e.g. JDSU ) */
> -       for (timeout =3D 0; timeout<  60; timeout++) {
> +       for (timeout =3D 0; timeout<  600; timeout++) {
>                  if (bnx2x_read_sfp_module_eeprom(params, 1, 1,&val)
>                      =3D=3D 0) {
>                          DP(NETIF_MSG_LINK, "SFP+ module initializati=
on "
>
> If it does help, be sure to let me know how much time it took (you
> should have this debug print).

Still no luck. :( The kernel printed many more "Got bad status 0x0 when=
=20
reading from SFP+ EEPROM" messages. Finally I got:
  "SFP+ module is not initialized".

Best regards,

			Krzysztof Ol=C4=99dzki
