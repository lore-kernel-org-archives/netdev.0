From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 4/7] Drivers: hv: vmbus: add APIs to register
 callbacks to process hvsock connection
Date: Wed, 29 Jul 2015 15:26:51 -0700 (PDT)
Message-ID: <20150729.152651.331017965932467028.davem@davemloft.net>
References: <1438086911-19384-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, gregkh@linuxfoundation.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
 stephen@networkplumber.org, stefanha@redhat.com, netdev@vger.kernel.org,
 apw@canonical.com, pebolle@tiscali.nl, dan.carpenter@oracle.com
To: decui@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1438086911-19384-1-git-send-email-decui@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Dexuan Cui <decui@microsoft.com>
Date: Tue, 28 Jul 2015 05:35:11 -0700

> With the 2 APIs supplied by the VMBus driver, the coming net/hvsock driver
> can register 2 callbacks and can know when a new hvsock connection is
> offered by the host, and when a hvsock connection is being closed by the
> host.
> 
> Signed-off-by: Dexuan Cui <decui@microsoft.com>

This is an extremely terrible interface.

It's an opaque hook that allows on registry, and it's solve purpose
is to allow a backdoor call into a foreign driver in another module.

These are exactly the things we try to avoid.

Why not create a real abstraction where clients register an object,
that can be contained as a sub-member inside of their own driver
private, that provides the callback registry mechanism.

That way you can register multiple clients, do things like allow
AF_PACKET capturing of vmbus traffic, etc.
