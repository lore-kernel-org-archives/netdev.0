From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] mlxsw: fix warnings for big-endian 32-bit dma_addr_t
Date: Wed, 7 Oct 2015 08:56:36 +0200
Message-ID: <20151007065636.GD2152@nanopsycho.orion>
References: <30258520.VaA2vDyUiY@wuerfel>
 <1444200782.26237.8.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	davem@davemloft.net, Jiri Pirko <jiri@mellanox.com>,
	Ido Schimmel <idosch@mellanox.com>,
	linux-kernel@vger.kernel.org, Elad Raz <eladr@mellanox.com>,
	Scott Feldman <sfeldma@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444200782.26237.8.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Oct 07, 2015 at 08:53:02AM CEST, joe@perches.com wrote:
>On Tue, 2015-10-06 at 23:47 +0200, Arnd Bergmann wrote:
>> The recently added mlxsw driver produces warnings in ARM
>> allmodconfig:
>> 
>> drivers/net/ethernet/mellanox/mlxsw/pci.c: In function 'mlxsw_pci_cmd_exec':
>> drivers/net/ethernet/mellanox/mlxsw/pci.c:1585:59: warning: right shift count >= width of type [-Wshift-count-overflow]
>> linux/byteorder/big_endian.h:38:51: note: in definition of macro '__cpu_to_be32'
>> drivers/net/ethernet/mellanox/mlxsw/pci.c:76:2: note: in expansion of macro 'iowrite32be'
>> 
>> This changes the type of the local variable to u64, which gets rid of the
>> warning and seems nicer than adding #ifdefs.
>
>Using upper_32_bits instead of the shift might be
>nicer than changing the type.

Wasn't aware of this macro. Indeed this looks more appropriate. Thanks!
