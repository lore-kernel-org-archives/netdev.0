From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH] vhost-net: utilize PUBLISH_USED_IDX feature
Date: Wed, 19 May 2010 20:04:51 +0300
Message-ID: <4BF41A33.8090309@redhat.com>
References: <20100518011931.GA21918@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Juan Quintela <quintela@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, alex.williamson@redhat.com,
	amit.shah@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100518011931.GA21918@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/18/2010 04:19 AM, Michael S. Tsirkin wrote:
> With PUBLISH_USED_IDX, guest tells us which used entries
> it has consumed. This can be used to reduce the number
> of interrupts: after we write a used entry, if the guest has not yet
> consumed the previous entry, or if the guest has already consumed the
> new entry, we do not need to interrupt.
> This imporves bandwidth by 30% under some workflows.
>
> Signed-off-by: Michael S. Tsirkin<mst@redhat.com>
> ---
>
> Rusty, Dave, this patch depends on the patch
> "virtio: put last seen used index into ring itself"
> which is currently destined at Rusty's tree.
> Rusty, if you are taking that one for 2.6.35, please
> take this one as well.
> Dave, any objections?
>    

I object: I think the index should have its own cacheline, and that it 
should be documented before merging.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.
