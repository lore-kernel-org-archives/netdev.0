From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: scsi: constify target_core_fabric_ops structures
Date: Tue, 10 Jan 2017 17:13:27 +0200
Message-ID: <20170110171201-mutt-send-email-mst@kernel.org>
References: <1483975262-1260-1-git-send-email-bhumirks@gmail.com>
	<20170110071054-mutt-send-email-mst@kernel.org>
	<CAOH+1jG4xohEaTTcgXPq2SA6T8yM-Q8oMEMS3iwyp+0RQnxkUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <CAOH+1jG4xohEaTTcgXPq2SA6T8yM-Q8oMEMS3iwyp+0RQnxkUg@mail.gmail.com>
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

On Tue, Jan 10, 2017 at 06:11:25PM +0530, Bhumika Goyal wrote:
> On Tue, Jan 10, 2017 at 10:41 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > On Mon, Jan 09, 2017 at 08:51:02PM +0530, Bhumika Goyal wrote:
> >> Declare target_core_fabric_ops strucrues as const as they are only
> >> passed as an argument to the functions target_register_template and
> >> target_unregister_template. The arguments are of type const struct
> >> target_core_fabric_ops *, so target_core_fabric_ops structures having
> >> this property can be declared const.
> >> Done using Coccinelle:
> >>
> >> @r disable optional_qualifier@
> >> identifier i;
> >> position p;
> >> @@
> >> static struct target_core_fabric_ops i@p={...};
> >>
> >> @ok@
> >> position p;
> >> identifier r.i;
> >> @@
> >> (
> >> target_register_template(&i@p)
> >> |
> >> target_unregister_template(&i@p)
> >> )
> >> @bad@
> >> position p!={r.p,ok.p};
> >> identifier r.i;
> >> @@
> >> i@p
> >>
> >> @depends on !bad disable optional_qualifier@
> >> identifier r.i;
> >> @@
> >> +const
> >> struct target_core_fabric_ops i;
> >>
> >> File size before: drivers/vhost/scsi.o
> >>    text          data     bss     dec     hex filename
> >>   18063          2985      40   21088    5260 drivers/vhost/scsi.o
> >>
> >> File size after: drivers/vhost/scsi.o
> >>    text          data     bss     dec     hex filename
> >>   18479          2601      40   21120    5280 drivers/vhost/scsi.o
> >
> > What are these numbers trying to prove?
> >
> 
> These numbers show that adding const has decreased the size of the
> data segment and increased the size of the text segment, suggesting
> that the changed code has been compiled and the const annotation has
> had an effect.
> 
> Thanks,
> Bhumika

I wonder why there's a net increase in memory consumption though.


> >
> >> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
> >> ---
> >>  drivers/vhost/scsi.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
> >> index 253310c..620366d 100644
> >> --- a/drivers/vhost/scsi.c
> >> +++ b/drivers/vhost/scsi.c
> >> @@ -2087,7 +2087,7 @@ static void vhost_scsi_drop_tport(struct se_wwn *wwn)
> >>       NULL,
> >>  };
> >>
> >> -static struct target_core_fabric_ops vhost_scsi_ops = {
> >> +static const struct target_core_fabric_ops vhost_scsi_ops = {
> >>       .module                         = THIS_MODULE,
> >>       .name                           = "vhost",
> >>       .get_fabric_name                = vhost_scsi_get_fabric_name,
> >
> > If it can be const it probably should ...
> >
> >> --
> >> 1.9.1
