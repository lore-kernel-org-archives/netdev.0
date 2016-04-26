From: Pankaj Gupta <pagupta@redhat.com>
Subject: Re: [PATCH 2/2] vhost: lockless enqueuing
Date: Tue, 26 Apr 2016 03:57:10 -0400 (EDT)
Message-ID: <19697601.46250110.1461657430875.JavaMail.zimbra@redhat.com>
References: <1461636873-45335-1-git-send-email-jasowang@redhat.com>
	<1461636873-45335-2-git-send-email-jasowang@redhat.com>
	<2033086948.46236145.1461651858100.JavaMail.zimbra@redhat.com>
	<571F1330.7030504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <571F1330.7030504@redhat.com>
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


> 
> 
> 
> On 04/26/2016 02:24 PM, Pankaj Gupta wrote:
> > Hi Jason,
> >
> > Overall patches look good. Just one doubt I have is below:
> >> We use spinlock to synchronize the work list now which may cause
> >> unnecessary contentions. So this patch switch to use llist to remove
> >> this contention. Pktgen tests shows about 5% improvement:
> >>
> >> Before:
> >> ~1300000 pps
> >> After:
> >> ~1370000 pps
> >>
> >> Signed-off-by: Jason Wang <jasowang@redhat.com>
> >> ---
> >>  drivers/vhost/vhost.c | 52
> >>  +++++++++++++++++++++++++--------------------------
> >>  drivers/vhost/vhost.h |  7 ++++---
> >>  2 files changed, 29 insertions(+), 30 deletions(-)
> 
> [...]
> 
> >> -		if (work) {
> >> +		node = llist_del_all(&dev->work_list);
> >> +		if (!node)
> >> +			schedule();
> >> +
> >> +		node = llist_reverse_order(node);
> > Can we avoid llist reverse here?
> >
> 
> Probably not, this is because:
> 
> - we should process the work exactly the same order as they were queued,
> otherwise flush won't work
> - llist can only add a node to the head of list.

Got it.

Thanks,
> 
> Thanks
> 
