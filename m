From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next RFC PATCH 5/5] virtio-net: flow director support
Date: Tue, 6 Dec 2011 17:36:16 +0000
Message-ID: <1323192976.2772.3.camel@bwh-desktop>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
	<20111205085925.6116.94352.stgit@dhcp-8-146.nay.redhat.com>
	<1323117745.2887.31.camel@bwh-desktop>  <4EDDC35C.2070100@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <4EDDC35C.2070100@redhat.com>
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

On Tue, 2011-12-06 at 15:25 +0800, Jason Wang wrote:
> On 12/06/2011 04:42 AM, Ben Hutchings wrote:
[...]
> > This is not a proper implementation of ndo_rx_flow_steer.  If you steer
> > a flow by changing the RSS table this can easily cause packet reordering
> > in other flows.  The filtering should be more precise, ideally matching
> > exactly a single flow by e.g. VID and IP 5-tuple.
> >
> > I think you need to add a second hash table which records exactly which
> > flow is supposed to be steered.  Also, you must call
> > rps_may_expire_flow() to check whether an entry in this table may be
> > replaced; otherwise you can cause packet reordering in the flow that was
> > previously being steered.
> >
> > Finally, this function must return the table index it assigned, so that
> > rps_may_expire_flow() works.
> 
> Thanks for the explanation, how about document this briefly in scaling.txt?
[...]

I believe scaling.txt is intended for users/administrators, not
developers.

The documentation for implementers of accelerated RFS is in the comment
for struct net_device_ops and the commit message adding it.  But I
really should improve that comment.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
