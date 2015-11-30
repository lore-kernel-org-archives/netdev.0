From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] basic busy polling support for vhost_net
Date: Sun, 29 Nov 2015 22:31:10 -0500 (EST)
Message-ID: <20151129.223110.1579432138646337508.davem@davemloft.net>
References: <1448435489-5949-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1448435489-5949-1-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Wed, 25 Nov 2015 15:11:26 +0800

> This series tries to add basic busy polling for vhost net. The idea is
> simple: at the end of tx/rx processing, busy polling for new tx added
> descriptor and rx receive socket for a while. The maximum number of
> time (in us) could be spent on busy polling was specified ioctl.
> 
> Test A were done through:
> 
> - 50 us as busy loop timeout
> - Netperf 2.6
> - Two machines with back to back connected ixgbe
> - Guest with 1 vcpu and 1 queue
> 
> Results:
> - For stream workload, ioexits were reduced dramatically in medium
>   size (1024-2048) of tx (at most -43%) and almost all rx (at most
>   -84%) as a result of polling. This compensate for the possible
>   wasted cpu cycles more or less. That porbably why we can still see
>   some increasing in the normalized throughput in some cases.
> - Throughput of tx were increased (at most 50%) expect for the huge
>   write (16384). And we can send more packets in the case (+tpkts were
>   increased).
> - Very minor rx regression in some cases.
> - Improvemnt on TCP_RR (at most 17%).

Michael are you going to take this?  It's touching vhost core as
much as it is the vhost_net driver.
