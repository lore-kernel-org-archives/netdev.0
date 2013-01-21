From: yuval.shaia@oracle.com
Subject: Re: [PATCH] Add support for netconsole driver used on bridge device
 with VIF attached
Date: Mon, 21 Jan 2013 20:00:35 +0200
Message-ID: <50FD8243.6000501@oracle.com>
References: <5757e54b-902b-4338-8ac9-43857cd1906c@default> <1358789308.3279.271.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:16428 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752768Ab3AUSBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 13:01:02 -0500
In-Reply-To: <1358789308.3279.271.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 01/21/2013 07:28 PM, Ian Campbell wrote:
> On Mon, 2013-01-21 at 17:17 +0000, Yuval Shaia wrote:
>
>> When starting a VM which has virtual interface attached to the same
>> bridge (i.e vif = [type=netfront,bridge=xenbr0'] in vm.cfg) which is
>> used for netconsole the
>> following message appears (after about 60 seconds) and VM creation
>> operation fails.
>>        Error: Device 0 (vif) could not be connected. Hotplug scripts not
>> working.
> I'm not sure how this can relate netconsole since this happens before
> the guest even runs, doesn't it?
Running the same scenario without netconsole runs smoothly.
>
>> As i see it, netconsole driver requires ndo_poll_controller from the
>> device's controlling driver (function __netpoll_setup in
>> net/core/netpoll.c), a thing that is not supported currently in
>> xen_netback driver which is the driver that runs on dom0 and serve
>> VM's virtual interface.
> Which domain is using netconsole? Is it dom0 or domU? What parameters do
> you give it?
dom0.
parameters: netconsole=1111@src-ip/xenbr0,2002@dst-ip/dst-mac
>
> I assume it is the domU but if that's the case I don't see why a netback
> rather than netfront patch would be required.
>
> Or is dom0 doing netconsole where the log receiver is a domU?
Log received at dom0 as output of xm cr vm.cfg command.
netconsole is used on dom0 to monitor its log
>
> Ian.
>
