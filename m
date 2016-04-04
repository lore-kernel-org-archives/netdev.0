From: Petr Kulhavy <petr@barix.com>
Subject: Re: davinci-mdio: failing to connect to PHY
Date: Mon, 4 Apr 2016 16:01:28 +0200
Message-ID: <570273B8.1030205@barix.com>
References: <57022356.6010309@barix.com> <20160404123145.GE21828@lunn.ch>
 <5702710A.5010804@barix.com> <20160404135813.GA25131@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:35609 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755650AbcDDOBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 10:01:32 -0400
Received: by mail-lf0-f43.google.com with SMTP id c126so53279641lfb.2
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 07:01:31 -0700 (PDT)
In-Reply-To: <20160404135813.GA25131@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04.04.2016 15:58, Andrew Lunn wrote:
> On Mon, Apr 04, 2016 at 03:50:02PM +0200, Petr Kulhavy wrote:
>> Hi Andrew,
>>
>> thanks a lot for the link. In the meantime I've understood the issue
>> better. It is due to the fact that the PHY is pin-strapped to
>> address 1 and broadcast (at address 0) is  enabled. The Micrel
>> driver's config_init() disables the broadcast and the PHY stops
>> responding, which causes the troubles. The kernel 3.17 didn't
>> disable the broadcast and therefore it worked.
>>
>> I'm wondering how to solve or workaround this...
> One option is in your device tree is to explicitly list the phy on
> your mdio bus. Something like:
>
> &mdio {
>          status = "okay";
>
>          ethphy0: ethernet-phy@1 {
>                  reg = <1>;
>          };
> };
>
> This alone might be sufficient. If not, you need to reference the phy
> via a phandle in the ethernet node.
>
>
> &eth0 {
>          status = "okay";
>          phy-handle = <&ethphy0>;
> };
>
> 	Andrew
Thanks a lot, I'm going to try it out right now!

Cheers
Petr
