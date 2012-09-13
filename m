From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V3 1/2] IB/ipoib: Add rtnl_link_ops support
Date: Thu, 13 Sep 2012 13:54:59 +0300
Message-ID: <5051BB83.3010103@mellanox.com>
References: <1345724119-32110-1-git-send-email-ogerlitz@mellanox.com>  <1345724119-32110-2-git-send-email-ogerlitz@mellanox.com>  <Pine.GSO.4.63.1208291450330.1098@stinky-local.trash.net>  <5050668B.1010105@mellanox.com>  <CAKoUAr=8zZA9EgvJEVrd0a-Uw=zzksHj+5P2Sp3Lb4vXgSJRYA@mail.gmail.com> <1347462823.13103.1085.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rami Rosen <roszenrami@gmail.com>,
	Patrick McHardy <kaber@trash.net>, <netdev@vger.kernel.org>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:58311 "HELO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757551Ab2IMLD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 07:03:26 -0400
In-Reply-To: <1347462823.13103.1085.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/2012 18:13, Eric Dumazet wrote:
> It might be related to module load/unload udevd or some external 
> daemon can access sysfs files while you unload the module 

Hi Eric,

I see, the IPoIB add/delete child sysfs handlers (ipoib_vlan_add/delete) 
use
RTNL locking to protect against netdev changes while the handlers are in 
action.

IPoIB uses devide_create_file to add the sysfs entries, but doesn't care 
to use
device_remove_file as these entries sit under the netdevice 
/sys/class/net/DEV
directory and are removed by higher layer when DEV gets 
unregistered/deleted, I'm
not sure if/how the driver is supposed to protect against access to 
these entries
while going down, when the module is unloaded, etc, any idea will be 
appreciated.


Or.
