From: Amir Vadai <amirv@mellanox.com>
Subject: Re: Manual loading of mlx4_en
Date: Tue, 29 Jul 2014 13:44:54 +0300
Message-ID: <53D77B26.3070905@mellanox.com>
References: <1406627612.4498.16.camel@chaos.site>	<53D7748A.6040800@mellanox.com> <20140729123405.6802fbc4@endymion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:58288 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752876AbaG2KpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 06:45:03 -0400
In-Reply-To: <20140729123405.6802fbc4@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/29/2014 1:34 PM, Jean Delvare wrote:
> Hi Amir,
> 
> On Tue, 29 Jul 2014 13:16:42 +0300, Amir Vadai wrote:
>> On 7/29/2014 12:53 PM, Jean Delvare wrote:
>>> I have a usability concern with the mlx4_en ethernet network driver. The
>>> module aliases for all the supported devices are on the mlx4_core
>>> module, so mlx4_core gets loaded automatically, but mlx4_en does not. I
>>> must load mlx4_en manually (kernel 3.12.)
>>>
>>> May I ask why the mlx4 driver was split into mlx4_core and mlx4_en in
>>> the first place?
>> Connect-X card can support both Ethernet and Infiniband link layer - you
>> can switch between link layers without replacing the hardware.
>>
>> To prevent code duplication, there is a single lower layer driver -
>> mlx4_core and two separate upper layer drivers - mlx4_en and mlx4_ib.
>>
>> Since kernel 3.13 mlx4_core is loading automatically the upper layer
>> driver using request_module():
>> b046ffe net/mlx4_core: Load higher level modules according to ports type
> 
> Many thanks for the fast and detailed answer! I'll go backport this
> commit to kernel 3.12 (and 3.0, hopefully it doesn't have too many
> dependencies?)
> 

I don't think there is any dependency for that commit. If you're
backporting it, also take a small fix to it:
f24f790 net/mlx4_core: Load the Eth driver first

Amir
