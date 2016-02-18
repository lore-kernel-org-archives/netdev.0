From: John Holland <jotihojr@gmail.com>
Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on i211
 using a device tree blob V5
Date: Thu, 18 Feb 2016 14:43:59 +0100
Message-ID: <56C5CA9F.3000102@gmail.com>
References: <56C5A6BC.6030708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:32873 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1426185AbcBRNoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 08:44:02 -0500
Received: by mail-wm0-f44.google.com with SMTP id g62so25902703wme.0
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 05:44:01 -0800 (PST)
In-Reply-To: <56C5A6BC.6030708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/18/2016 12:10 PM, John Holland wrote:
> Hello,
>
> The Intel i211 LOM PCIe Ethernet controllers' iNVM operates as an OTP
> and has no external EEPROM interface [1]. The following allows the
> driver to pickup the MAC address from a device tree blob when CONFIG_OF
> has been enabled.
>
> +       if (eth_platform_get_mac_address(&pdev->dev, hw->mac.addr)) {

For later reference, putting all necessary information in one place.

This requires the dtb for the mac address routing to be properly 
positioned. On an imx6q using U-Boot, that required setting the U-Boot 
environment variable eth1addr and reworking the PCIe tree and allocating 
an alias as such:

1) Set intel,i211 MAC address.

# env set eth1addr <valid-mac-address>

2) Add an alias to pick up the MAC address from U-Boot and route it to 
the intel,i211 PCIe endpoint for an imx6qdl derivative.

/ {
         aliases {
                 ethernet1 = &eth1;
         };

};

&pcie {
         /* soc pcie bridge 00:00.0 */
         pcie@0,0 {
                 reg = <0x000000 0 0 0 0>;
                 #address-cells = <3>;
                 #size-cells = <2>;

                 /* pcie endpoint 01:00.0 */
                 eth1: intel,i211@pcie0,0 {
                         reg = <0x010000 0 0 0 0>;
                 };
         };
};

John
