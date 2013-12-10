From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 1/3] virtio_net: set multicast filter list to host
Date: Tue, 10 Dec 2013 23:07:43 +0200
Message-ID: <20131210210743.GA8629@redhat.com>
References: <20131209161632.5ac96e5a@nehalam.linuxnetplumber.net>
	<20131210152429.GB25293@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	virtualization@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20131210152429.GB25293@redhat.com>
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

On Tue, Dec 10, 2013 at 05:24:29PM +0200, Michael S. Tsirkin wrote:
> On Mon, Dec 09, 2013 at 04:16:32PM -0800, Stephen Hemminger wrote:
> > The virtio_net driver never sends the multicast address list to
> > the host. This is because send command takes a pointer to scatter list
> > to send but only inserts that one entry into the outgoing scatter list.
> > 
> > This bug has been there since:
> > commit f565a7c259d71cc186753653d978c646d2354b36
> > Author: Alex Williamson <alex.williamson@hp.com>
> > Date:   Wed Feb 4 09:02:45 2009 +0000
> > 
> >     virtio_net: Add a MAC filter table
> > 
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> 
> Question is, can we detect a broken driver in the host somehow?
> If not we'll need a feature bit for hosts to actually do
> MC filtering.


Hmm Vlad and Amos made some good points about this patch.
Dave, pls don't apply yet until these are resolved.

> > --- a/drivers/net/virtio_net.c	2013-12-09 16:12:03.897891975 -0800
> > +++ b/drivers/net/virtio_net.c	2013-12-09 16:12:36.353164803 -0800
> > @@ -893,7 +893,7 @@ static bool virtnet_send_command(struct
> >  	sg_init_one(&hdr, &ctrl, sizeof(ctrl));
> >  	sgs[out_num++] = &hdr;
> >  
> > -	if (out)
> > +	for (; out; out = sg_next(out))
> >  		sgs[out_num++] = out;
> >  	if (in)
> >  		sgs[out_num + in_num++] = in;
