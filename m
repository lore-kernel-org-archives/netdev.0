From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvtap: fix TUNSETSNDBUF values > 64k
Date: Sun, 20 Sep 2015 22:45:12 -0700 (PDT)
Message-ID: <20150920.224512.1934479578463693954.davem@davemloft.net>
References: <1442572808-6438-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mjrosato@linux.vnet.ibm.com,
	borntraeger@de.ibm.com, viro@zeniv.linux.org.uk,
	jasowang@redhat.com, david@gibson.dropbear.id.au,
	gkurz@linux.vnet.ibm.com, vyasevich@gmail.com, justin@myriabit.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442572808-6438-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Fri, 18 Sep 2015 13:41:09 +0300

> Upon TUNSETSNDBUF,  macvtap reads the requested sndbuf size into
> a local variable u.
> commit 39ec7de7092b ("macvtap: fix uninitialized access on
> TUNSETIFF") changed its type to u16 (which is the right thing to
> do for all other macvtap ioctls), breaking all values > 64k.
> 
> The value of TUNSETSNDBUF is actually a signed 32 bit integer, so
> the right thing to do is to read it into an int.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Fixes: 39ec7de7092b ("macvtap: fix uninitialized access on TUNSETIFF")
> Reported-by: Mark A. Peloquin
> Bisected-by: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
> Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied and queued up for -stable, thanks.
