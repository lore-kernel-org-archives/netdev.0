From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [RFC] kvm tools: Implement multiple VQ for virtio-net
Date: Sun, 13 Nov 2011 17:32:44 +0200
Message-ID: <1321198364.2425.5.camel@sasha>
References: <1321049521-26376-1-git-send-email-levinsasha928@gmail.com>
	<20111113102428.GD15322@redhat.com>  <1321196430.2425.2.camel@sasha>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2@in.ibm.com>, gorcunov@gmail.com,
	kvm@vger.kernel.org, asias.hejun@gmail.com,
	virtualization@lists.linux-foundation.org, penberg@kernel.org,
	netdev@vger.kernel.org, mingo@elte.hu
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1321196430.2425.2.camel@sasha>
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

On Sun, 2011-11-13 at 17:00 +0200, Sasha Levin wrote:
> On Sun, 2011-11-13 at 12:24 +0200, Michael S. Tsirkin wrote:
> > On Sat, Nov 12, 2011 at 12:12:01AM +0200, Sasha Levin wrote:
> > > This is a patch based on Krishna Kumar's patch series which implements
> > > multiple VQ support for virtio-net.
> > > 
> > > The patch was tested with ver3 of the patch.
> > > 
> > > Cc: Krishna Kumar <krkumar2@in.ibm.com>
> > > Cc: Michael S. Tsirkin <mst@redhat.com>
> > > Cc: Rusty Russell <rusty@rustcorp.com.au>
> > > Cc: virtualization@lists.linux-foundation.org
> > > Cc: netdev@vger.kernel.org
> > > Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> > 
> > Any performance numbers?
> 
> I tried finding a box with more than two cores so I could test it on
> something like that as well.
> 
> From what I see this patch causes a performance regression on my 2 core
> box.
> 

[snip]

After discussing it with Michael, we found out that for a single TCP
flow the guest signals the same TX VQ, but the RX VQ keeps changing -
which means that theres missing host-guest synchronization of hash flow.

-- 

Sasha.
