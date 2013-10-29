From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] virtio_net: migrate mergeable rx buffers to
	page frag allocators
Date: Tue, 29 Oct 2013 21:17:34 +0200
Message-ID: <20131029191734.GF20848@redhat.com>
References: <1383000258-1458-1-git-send-email-mwdalton@google.com>
	<CAG7+5M1VFSZciaZf+Y_yzm=aq1Z4fZ-QgACN2srnC9twOWhVWw@mail.gmail.com>
	<CANJ5vP+=wCrzJ3Fdg0_5ZTTT-V-fw2AXUG=EgwsUcxXO=UpMgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Michael Dalton <mwdalton@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <CANJ5vP+=wCrzJ3Fdg0_5ZTTT-V-fw2AXUG=EgwsUcxXO=UpMgw@mail.gmail.com>
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

On Tue, Oct 29, 2013 at 12:05:27PM -0700, Michael Dalton wrote:
> Agreed Eric, the buffer size should be increased so that we can accommodate a
> MTU-sized packet + mergeable virtio net header in a single buffer. I will send
> a patch to fix shortly cleaning up the #define headers as Rusty indicated and
> increasing the buffer size slightly by VirtioNet header size bytes per Eric.
> 
> Jason, I'll followup with you directly - I'd like to know your exact workload
> (single steam or multi-stream netperf?), VM configuration, etc, and also see if
> the nit that Erichas pointed out affects your results.  It is also
> worth noting that
> we may want to tune the queue sizes for your benchmarks, e.g, by reducing
> buffer size from 4KB to MTU-sized but keeping queue length constant, we're
> implicitly decreasing the number of bytes stored in the VirtioQueue for the
> VirtioNet device, so increasing the queue size may help.
> 
> Best,
> 
> Mike

Well we have 256 descriptors per queue, each descriptor is 16 bytes
already and they have to be physically contigious.
I don't think we can easily increase the queue size much more without
risking memory allocation failures on busy systems.

I guess one approach is to do something like:
	 if (queue size > 1024)
		 use small buffers
	 else
		 use 4K buffers.

That would reduce the risk of regressions for existing users.


-- 
MST
