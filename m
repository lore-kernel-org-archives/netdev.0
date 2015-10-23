From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next RFC 1/2] vhost: introduce vhost_has_work()
Date: Fri, 23 Oct 2015 15:10:44 +0800
Message-ID: <5629DD74.1090702@redhat.com>
References: <1445491649-62614-1-git-send-email-jasowang@redhat.com>
	<20151022113740-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20151022113740-mutt-send-email-mst@redhat.com>
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



On 10/22/2015 04:38 PM, Michael S. Tsirkin wrote:
> On Thu, Oct 22, 2015 at 01:27:28AM -0400, Jason Wang wrote:
>> > This path introduces a helper which can give a hint for whether or not
>> > there's a work queued in the work list.
>> > 
>> > Signed-off-by: Jason Wang <jasowang@redhat.com>
>> > ---
>> >  drivers/vhost/vhost.c | 6 ++++++
>> >  drivers/vhost/vhost.h | 1 +
>> >  2 files changed, 7 insertions(+)
>> > 
>> > diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
>> > index eec2f11..d42d11e 100644
>> > --- a/drivers/vhost/vhost.c
>> > +++ b/drivers/vhost/vhost.c
>> > @@ -245,6 +245,12 @@ void vhost_work_queue(struct vhost_dev *dev, struct vhost_work *work)
>> >  }
>> >  EXPORT_SYMBOL_GPL(vhost_work_queue);
>> >  
>> > +bool vhost_has_work(struct vhost_dev *dev)
>> > +{
>> > +	return !list_empty(&dev->work_list);
>> > +}
>> > +EXPORT_SYMBOL_GPL(vhost_has_work);
>> > +
>> >  void vhost_poll_queue(struct vhost_poll *poll)
>> >  {
>> >  	vhost_work_queue(poll->dev, &poll->work);
> This doesn't take a lock so it's unreliable.
> I think it's ok in this case since it's just
> an optimization - but pls document this.
>

Ok, will do.
