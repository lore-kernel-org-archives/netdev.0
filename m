From: Ed Swierk <eswierk@aristanetworks.com>
Subject: Re: [PATCH 1/2] macvtap: rework object lifetime rules
Date: Mon, 15 Feb 2010 15:48:40 -0800
Message-ID: <9ae48b021002151548l79b8c5fdycc04a2f36fed1f09@mail.gmail.com>
References: <201002131133.43028.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Sridhar Samudrala <sri@us.ibm.com>, qemu-devel@nongnu.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201002131133.43028.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 13, 2010 at 2:33 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> The original macvtap code has a number of problems
> resulting from the use of RCU for protecting the
> access to struct macvtap_queue from open files.
>
> This includes
> - need for GFP_ATOMIC allocations for skbs
> - potential deadlocks when copy_*_user sleeps
> - inability to work with vhost-net
>
> Changing the lifetime of macvtap_queue to always
> depend on the open file solves all these. The
> RCU reference simply moves one step down to
> the reference on the macvlan_dev, which we
> only need for nonblocking operations.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

This works for me.

Acked-by: Ed Swierk <eswierk@aristanetworks.com>
