From: "Du, Fan" <fan.du@intel.com>
Subject: Re: GSO packets on lower MTU retaining gso_size?
Date: Tue, 07 Jun 2016 14:46:06 +0800
Message-ID: <57566DAE.4010609@intel.com>
References: <CO2PR11MB008861B24F9DA5CBA56F58C8975D0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:54194 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753457AbcFGGqO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 02:46:14 -0400
In-Reply-To: <CO2PR11MB008861B24F9DA5CBA56F58C8975D0@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/6/7 14:05, Yuval Mintz wrote:
> While experimenting with Vxlan tunnels, I've reached a topology where the
> Vxlan interface's MTU was 1500 while base-interface was smaller [600].
>
> While 'regular' packets broke via ip-fragmentation, GSO SKBs passing from
> the vxlan interface to the base interface remained whole, and their
> `gso_size' remained matching to that of the vxlan-interface's MTU;
> This caused the HW to drop said packets, as it would have resulted with
> the device sending to the line packets with length larger than the mtu.
>
> Is this broken on the udp-tunnel transmit path, the setup or the driver [qede]?

I believe it's identical to issue I met before[1], the owner of the 
offending code
believe a host can't generate packet size larger than the underlying NIC 
MTU and
refuse to do the GSO here.

[1]: https://patchwork.ozlabs.org/patch/415791/
