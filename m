From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 V2] Drivers: net-next: hyperv: Increase the size of
 the sendbuf region
Date: Mon, 04 Aug 2014 15:07:42 -0700 (PDT)
Message-ID: <20140804.150742.936539469729151133.davem@davemloft.net>
References: <1407001322-12010-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1407001322-12010-1-git-send-email-kys@microsoft.com>
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
Date: Sat,  2 Aug 2014 10:42:02 -0700

> Intel did some benchmarking on our network throughput when Linux on Hyper-V
> is as used as a gateway. This fix gave us almost a 1 Gbps additional throughput
> on about 5Gbps base throughput we hadi, prior to increasing the sendbuf size.
> The sendbuf mechanism is a copy based transport that we have which is clearly
> more optimal than the copy-free page flipping mechanism (for small packets).
> In the forwarding scenario, we deal only with MTU sized packets,
> and increasing the size of the senbuf area gave us the additional performance.
> For what it is worth, Windows guests on Hyper-V, I am told use similar sendbuf
> size as well.
> 
> The exact value of sendbuf I think is less important than the fact that it needs
> to be larger than what Linux can allocate as physically contiguous memory.
> Thus the change over to allocating via vmalloc().
> 
> We currently allocate 16MB receive buffer and we use vmalloc there for allocation.
> Also the low level channel code has already been modified to deal with physically
> dis-contiguous memory in the ringbuffer setup.
> 
> Based on experimentation Intel did, they say there was some improvement in throughput
> as the sendbuf size was increased up to 16MB and there was no effect on throughput
> beyond 16MB. Thus I have chosen 16MB here.
> 
> Increasing the sendbuf value makes a material difference in small packet handling
> 
> In this version of the patch, based on David's feedback, I have added
> additional details in the commit log.
> 
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

APplied.
