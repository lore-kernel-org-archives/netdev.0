From: Dinh Nguyen <dinh.linux@gmail.com>
Subject: Re: socfpga/sockit ethernet problems
Date: Thu, 08 May 2014 10:28:41 -0500
Message-ID: <536BA2A9.2080908@gmail.com>
References: <20140507104518.GB18139@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Pavel Machek <pavel@denx.de>, peppe.cavallaro@st.com,
	netdev@vger.kernel.org, dinguyen@altera.com,
	linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:36276 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752733AbaEHP2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 11:28:45 -0400
Received: by mail-oa0-f44.google.com with SMTP id i11so3290339oag.3
        for <netdev@vger.kernel.org>; Thu, 08 May 2014 08:28:44 -0700 (PDT)
In-Reply-To: <20140507104518.GB18139@amd.pavel.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 05/07/2014 05:45 AM, Pavel Machek wrote:
> Hi!
>
> It seems we have some problems with Ethernet on socfpga boards.
>
> Like, "stmmac: Energy-Efficient Ethernet initialized" repeated way too
> often. Or machine failing to boot because NFS server can not be

There's a patch that already mainlined that fixes this:

83bf79b6bb stmmac: disable at run-time the EEE if not supported


> accessed. (And then working on next try). Or link going up and down
> and up and down. Or link taking 3 seconds, 10 seconds to estabilish.
>
> It also seems to be picky about hubs it wants to talk to.
>
> This time it mounted root; on last boot it just hung.
>
> Mounts root 31.394855 Waiting 5 sec before mounting root device...
> Mounts root 33.331379 stmmaceth ff702000.ethernet eth0: Link is Up -
> 100Mbps/Full - flow control rx/tx
> Mounts root 36.418308 VFS: Mounted root (nfs filesystem) on device
> 0:12.
> ### Milestone reached:  Mounts root
> Userland boots 51.455751 nfs: server 192.168.1.1 not responding, still
> trying
> Userland boots 52.552075 nfs: server 192.168.1.1 OK
> Userland boots 52.555110 devtmpfs: mounted
> Userland boots 52.566032 Freeing unused kernel memory: 264K (80597000
> - 805d9000)
> Userland boots 61.395175 nfs: server 192.168.1.1 not responding, still
> trying
> Userland boots 61.401301 nfs: server 192.168.1.1 OK
>
> U-boot seems to configure phy timing:
>
> u-boot talk 12.033741 Configuring PHY skew timing for Micrel ksz9021
>
> is there something similar that needs to be done at Linux layer.

I haven't tested in the sockit, but I have been testing on the devkit, 
and I am able to NFS mount just fine everytime.

I have a branch at:

git://git.rocketboards.org/linux-socfpga-next.git  for-next

that you can test.

Dinh
>
> Any ideas? Thanks,
> 									Pavel
>
