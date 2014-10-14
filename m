From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/3] virtio_net: pass well-formed sgs to virtqueue_add_*()
Date: Tue, 14 Oct 2014 12:51:47 +1030
Message-ID: <877g03crwk.fsf@rustcorp.com.au>
References: <1409718556-3041-1-git-send-email-rusty@rustcorp.com.au>
	<1409718556-3041-2-git-send-email-rusty__16380.2289790057$1409718628$gmane$org@rustcorp.com.au>
	<54099332.7060909@redhat.com> <20140907072032.GA25143@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20140907072032.GA25143@redhat.com>
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

"Michael S. Tsirkin" <mst@redhat.com> writes:
> On Fri, Sep 05, 2014 at 12:40:50PM +0200, Paolo Bonzini wrote:
>> Il 03/09/2014 06:29, Rusty Russell ha scritto:
>> > +	sg_init_table(rq->sg, MAX_SKB_FRAGS + 2);
>> 
>> I think 2 is enough here.  That said...
>> 
>> >  	sg_set_buf(rq->sg, &hdr->hdr, sizeof hdr->hdr);
>> > -
>> >  	skb_to_sgvec(skb, rq->sg + 1, 0, skb->len);
>> >  
>> >  	err = virtqueue_add_inbuf(rq->vq, rq->sg, 2, skb, gfp);
>> 
>> ... skb_to_sgvec will already make the sg well formed, so the
>> sg_init_table is _almost_ redundant; it is only there to remove
>> intermediate end marks.  The block layer takes care to remove
>> them, but skb_to_sgvec doesn't.

sg_init_table is still needed if CONFIG_DEBUG_SG, so I don't
think it's worth it.

Thanks,
Rusty.
