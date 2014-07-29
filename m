From: Amir Vadai <amirv@mellanox.com>
Subject: Re: Manual loading of mlx4_en
Date: Tue, 29 Jul 2014 13:16:42 +0300
Message-ID: <53D7748A.6040800@mellanox.com>
References: <1406627612.4498.16.camel@chaos.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jean Delvare <jdelvare@suse.de>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:38161 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753221AbaG2KWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 06:22:23 -0400
In-Reply-To: <1406627612.4498.16.camel@chaos.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 7/29/2014 12:53 PM, Jean Delvare wrote:
> Hi all,
> 
> I have a usability concern with the mlx4_en ethernet network driver. The
> module aliases for all the supported devices are on the mlx4_core
> module, so mlx4_core gets loaded automatically, but mlx4_en does not. I
> must load mlx4_en manually (kernel 3.12.)
> 
> May I ask why the mlx4 driver was split into mlx4_core and mlx4_en in
> the first place?
Connect-X card can support both Ethernet and Infiniband link layer - you
can switch between link layers without replacing the hardware.

To prevent code duplication, there is a single lower layer driver -
mlx4_core and two separate upper layer drivers - mlx4_en and mlx4_ib.

Since kernel 3.13 mlx4_core is loading automatically the upper layer
driver using request_module():
b046ffe net/mlx4_core: Load higher level modules according to ports type

> 
> I have worked around the problem with the following modprobe directive:
> 
> install mlx4_core /sbin/modprobe --ignore-install mlx4_core && /sbin/modprobe mlx4_en
> 
> But this is kind of a hack and I would expect the right driver to load
> automatically without magic.
> 
> Shouldn't the module aliases be attached to mlx4_en instead of
> mlx4_core?
> 
> Thanks,
> 

Amir
