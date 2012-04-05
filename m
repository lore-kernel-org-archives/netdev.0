From: Jason Wang <jasowang@redhat.com>
Subject: Re: question about napi_disable (was Re: [PATCH] virtio_net:
	set/cancel work on ndo_open/ndo_stop)
Date: Thu, 05 Apr 2012 14:32:03 +0800
Message-ID: <4F7D3C63.1080601@redhat.com>
References: <87hb0kgiwn.fsf@rustcorp.com.au> <87pqf7fyld.fsf@rustcorp.com.au>
	<20120404093229.GA3804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	virtualization@lists.linux-foundation.org,
	Amit Shah <amit.shah@redhat.com>, David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120404093229.GA3804@redhat.com>
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

On 04/04/2012 05:32 PM, Michael S. Tsirkin wrote:
> On Thu, Dec 29, 2011 at 09:12:38PM +1030, Rusty Russell wrote:
>> >  Michael S. Tsirkin noticed that we could run the refill work after
>> >  ndo_close, which can re-enable napi - we don't disable it until
>> >  virtnet_remove.  This is clearly wrong, so move the workqueue control
>> >  to ndo_open and ndo_stop (aka. virtnet_open and virtnet_close).
>> >  
>> >  One subtle point: virtnet_probe() could simply fail if it couldn't
>> >  allocate a receive buffer, but that's less polite in virtnet_open() so
>> >  we schedule a refill as we do in the normal receive path if we run out
>> >  of memory.
>> >  
>> >  Signed-off-by: Rusty Russell<rusty@rustcorp.com.au>
> Doh.
> napi_disable does not prevent the following
> napi_schedule, does it?
>
> Can someone confirm that I am not seeing things please?
Looks like napi_disable() does prevent the following scheduling, as 
napi_schedule_prep() returns true only when there's an 0 -> 1 transition 
of NAPI_STATE_SCHED bit.
