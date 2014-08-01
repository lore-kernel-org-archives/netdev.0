From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Drivers: net-next: hyperv: Increase the size of
 the sendbuf region
Date: Thu, 31 Jul 2014 21:59:07 -0700 (PDT)
Message-ID: <20140731.215907.860867918938148695.davem@davemloft.net>
References: <1406770549-29982-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1406770549-29982-1-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Wed, 30 Jul 2014 18:35:49 -0700

> For forwarding scenarios, it will be useful to allocate larger
> sendbuf. Make the necessary adjustments to permit this.
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

This needs more information.

You're increasing the size by 16 times, 1MB --> 16MB, thus less
cache locality.

You're also now using vmalloc() memory, thus more TLB misses and
thrashing.

This must have a negative impact on performance, and you have to
test for that and quantify it when making a change as serious as
this one.

You also haven't gone into detail as to why forwarding scenerios
require more buffer space, than say thousands of local sockets
sending bulk TCP data.

I'm not applying this, it needs a lot more work.
