From: Pankaj Gupta <pagupta@redhat.com>
Subject: Re: [PATCH v3 net-next 2/2 tuntap: Increase the number of queues in
 tun.
Date: Wed, 10 Dec 2014 02:56:45 -0500 (EST)
Message-ID: <575321203.11353864.1418198205135.JavaMail.zimbra@redhat.com>
References: <1417591177-7985-1-git-send-email-pagupta@redhat.com> <1417591177-7985-3-git-send-email-pagupta@redhat.com> <20141203095210.GC9487@redhat.com> <1417661734.16500.0@smtp.corp.redhat.com> <20141204102013.GC17122@redhat.com> <5481602E.1030508@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, dgibson@redhat.com, vfalico@gmail.com,
	edumazet@google.com, vyasevic@redhat.com, hkchu@google.com,
	wuzhy@linux.vnet.ibm.com, xemul@parallels.com, therbert@google.com,
	bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org, jiri@resnulli.us,
	sergei shtylyov <sergei.shtylyov@cogentembedded.com>
To: Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5481602E.1030508@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
> On 12/04/2014 06:20 PM, Michael S. Tsirkin wrote:
> > On Thu, Dec 04, 2014 at 03:03:34AM +0008, Jason Wang wrote:
> >> > 
> >> > 
> >> > On Wed, Dec 3, 2014 at 5:52 PM, Michael S. Tsirkin <mst@redhat.com>
> >> > wrote:
> >>> > >On Wed, Dec 03, 2014 at 12:49:37PM +0530, Pankaj Gupta wrote:
> >>>> > >> Networking under kvm works best if we allocate a per-vCPU RX and TX
> >>>> > >> queue in a virtual NIC. This requires a per-vCPU queue on the host
> >>>> > >>side.
> >>>> > >> It is now safe to increase the maximum number of queues.
> >>>> > >> Preceding patche: 'net: allow large number of rx queues'
> >>> > >
> >>> > >s/patche/patch/
> >>> > >
> >>>> > >> made sure this won't cause failures due to high order memory
> >>>> > >> allocations. Increase it to 256: this is the max number of vCPUs
> >>>> > >> KVM supports.
> >>>> > >> Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
> >>>> > >> Reviewed-by: David Gibson <dgibson@redhat.com>
> >>> > >
> >>> > >Hmm it's kind of nasty that each tun device is now using x16 memory.
> >>> > >Maybe we should look at using a flex array instead, and removing the
> >>> > >limitation altogether (e.g. make it INT_MAX)?
> >> > 
> >> > But this only happens when IFF_MULTIQUEUE were used.
> > I refer to this field:
> >         struct tun_file __rcu   *tfiles[MAX_TAP_QUEUES];
> > if we make MAX_TAP_QUEUES 256, this will use 4K bytes,
> > apparently unconditionally.
> >
> >
> 
> How about just allocate one tfile if IFF_MULTIQUEUE were disabled?

Yes, we can also go with one tfile if for single queue. 

As tfiles is array of 'tun_file' pointers with size 256. For multiqueue
we would be using 256 queues. But for single queue if we have one tfile
makes sense.

Also, we are making sure to avoid memory failures with vzalloc.

> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
