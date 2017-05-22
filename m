From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: fix randomly populated arp target array
Date: Mon, 22 May 2017 14:38:46 -0400 (EDT)
Message-ID: <20170522.143846.1648727051789760165.davem@davemloft.net>
References: <20170519184646.42572-1-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, maheshb@google.com,
        j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        netdev@vger.kernel.org, stable@vger.kernel.org
To: jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170519184646.42572-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarod Wilson <jarod@redhat.com>
Date: Fri, 19 May 2017 14:46:46 -0400

> In commit dc9c4d0fe023, the arp_target array moved from a static global
> to a local variable. By the nature of static globals, the array used to
> be initialized to all 0. At present, it's full of random data, which
> that gets interpreted as arp_target values, when none have actually been
> specified. Systems end up booting with spew along these lines:
 ...
> None of these were actually specified as ARP targets, and the driver does
> seem to clean up the mess okay, but it's rather noisy and confusing, leaks
> values to userspace, and the 255.255.255.255 spew shows up even when debug
> prints are disabled.
> 
> The fix: just zero out arp_target at init time.
> 
> While we're in here, init arp_all_targets_value in the right place.
> 
> Fixes: dc9c4d0fe023 ("bonding: reduce scope of some global variables")
> CC: Mahesh Bandewar <maheshb@google.com>
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: netdev@vger.kernel.org
> CC: stable@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>

Whoops... applied, thanks Jarod.
