From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 5/6] net: fix sock locking for sk_err field in
 netlink.
Date: Thu, 17 Sep 2009 18:27:45 -0700 (PDT)
Message-ID: <20090917.182745.230999703.davem@davemloft.net>
References: <20090918005708.25594.52575.stgit@localhost.localdomain>
	<20090918005832.25594.45086.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	linux-scsi@vger.kernel.org, john.r.fastabend@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090918005832.25594.45086.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 17 Sep 2009 17:58:32 -0700

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> This adds the sock lock around setting the sk_err field
> in sock struct. Without the lock multiple threads may
> write to this field.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

This isn't right.

Writes to sk->sk_err can occur asynchronously just fine and
without any locking.

The only requirement is that consumers of the sk_err value
use sock_error() which uses xchg() to get and clear the
value atomically.
