From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ns83820: Avoid bad pointer deref in ns83820_init_one().
Date: Tue, 18 Jan 2011 16:14:31 -0800 (PST)
Message-ID: <20110118.161431.245411919.davem@davemloft.net>
References: <alpine.LNX.2.00.1101172116330.27021@swampdragon.chaosbits.net>
	<20110118164200.GI17839@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jj@chaosbits.net, netdev@vger.kernel.org, linux-ns83820@kvack.org,
	linux-kernel@vger.kernel.org, tj@kernel.org, segooon@gmail.com,
	dkirjanov@kernel.org
To: bcrl@kvack.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110118164200.GI17839@kvack.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Tue, 18 Jan 2011 11:42:00 -0500

> On Mon, Jan 17, 2011 at 09:24:57PM +0100, Jesper Juhl wrote:
>> In drivers/net/ns83820.c::ns83820_init_one() we dynamically allocate 
>> memory via alloc_etherdev(). We then call PRIV() on the returned storage 
>> which is 'return netdev_priv()'. netdev_priv() takes the pointer it is 
>> passed and adds 'ALIGN(sizeof(struct net_device), NETDEV_ALIGN)' to it and 
>> returns it. Then we test the resulting pointer for NULL, which it is 
>> unlikely to be at this point, and later dereference it. This will go bad 
>> if alloc_etherdev() actually returned NULL.
>> 
>> This patch reworks the code slightly so that we test for a NULL pointer 
>> (and return -ENOMEM) directly after calling alloc_etherdev().
> 
> Looks good.
> 
> 		-ben
> 
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

Applied, thanks everyone.
