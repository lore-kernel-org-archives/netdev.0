From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 3/3] virtio_ring: unify direct/indirect code paths.
Date: Mon, 8 Sep 2014 10:32:07 -0700
Message-ID: <CALCETrUY1=jkJTQvCLSSOYw5O9M2N3o1AiT9AnzYE3zQU319TQ@mail.gmail.com>
References: <1409718556-3041-1-git-send-email-rusty@rustcorp.com.au>
	<1409718556-3041-4-git-send-email-rusty@rustcorp.com.au>
	<540996A9.4060100@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Linux Virtualization <virtualization@lists.linux-foundation.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Paolo Bonzini <pbonzini@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <540996A9.4060100@redhat.com>
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

On Sep 5, 2014 3:55 AM, "Paolo Bonzini" <pbonzini@redhat.com> wrote:
>
> Il 03/09/2014 06:29, Rusty Russell ha scritto:
> > +     desc = kmalloc(total_sg * sizeof(struct vring_desc), gfp);
> > +     if (!desc)
> > +             return NULL;
> >
> > -     return head;
> > +     for (i = 0; i < total_sg; i++)
> > +             desc[i].next = i+1;
> > +     return desc;
> >  }
>
> Would it make sense to keep a cache of a few (say) 8- or 16-element
> indirect descriptors?  You'd only have to do this ugly (and slowish) for
> loop on the first allocation.
>
> Also, since this is mostly an aesthetic patch,
>
> > +     if (indirect)
> > +             vq->free_head = vq->vring.desc[head].next;
> > +     else
> > +             vq->free_head = i;
>
> I'd move the indirect case above, where the vring.desc[head] is actually
> allocated.
>

Please don't: I'll just have to undo it for the DMA API stuff, since
descriptor setup will be able to fail.

--Andy
