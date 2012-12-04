From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [net-next rfc v7 1/3] virtio-net: separate fields of
	sending/receiving queue from virtnet_info
Date: Tue, 04 Dec 2012 14:13:11 +1030
Message-ID: <87zk1uh48g.fsf@rustcorp.com.au>
References: <1354011360-39479-1-git-send-email-jasowang@redhat.com>
	<1354011360-39479-2-git-send-email-jasowang@redhat.com>
	<87y5hfj3vl.fsf@rustcorp.com.au>
	<3524590.ZWGua7A8ne@jason-thinkpad-t430s>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	bhutchings@solarflare.com, jwhan@filewood.snu.ac.kr, shiyer@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <3524590.ZWGua7A8ne@jason-thinkpad-t430s>
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

Jason Wang <jasowang@redhat.com> writes:
> On Monday, December 03, 2012 12:25:42 PM Rusty Russell wrote:
>> > +
>> > +	/* Work struct for refilling if we run low on memory. */
>> > +	struct delayed_work refill;
>> 
>> I can't really see the justificaiton for a refill per queue.  Just have
>> one work iterate all the queues if it happens, unless it happens often
>> (in which case, we need to look harder at this anyway).
>
> But during this kind of iteration, we may need enable/disable the napi 
> regardless of whether the receive queue has lots to be refilled. This may add 
> extra latency. 

Sure, but does it actually happen?  We only use the work when we run out
of memory.  If this happens in normal behaviour we need to change
something else...

Thanks,
Rusty.
