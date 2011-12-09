From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [net-next RFC PATCH 0/5] Series short description
Date: Fri, 09 Dec 2011 16:01:53 +1030
Message-ID: <87r50efgza.fsf@rustcorp.com.au>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
	<87ty5cj0sw.fsf@rustcorp.com.au> <4EDF4E82.7050201@redhat.com>
	<1323277324.2728.34.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com
To: Ben Hutchings <bhutchings@solarflare.com>, Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1323277324.2728.34.camel@bwh-desktop>
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

On Wed, 7 Dec 2011 17:02:04 +0000, Ben Hutchings <bhutchings@solarflare.com> wrote:
> Solarflare controllers (sfc driver) have 8192 perfect filters for
> TCP/IPv4 and UDP/IPv4 which can be used for flow steering.  (The filters
> are organised as a hash table, but matched based on 5-tuples.)  I
> implemented the 'accelerated RFS' interface in this driver.
> 
> I believe the Intel 82599 controllers (ixgbe driver) have both
> hash-based and perfect filter modes and the driver can be configured to
> use one or the other.  The driver has its own independent mechanism for
> steering RX and TX flows which predates RFS; I don't know whether it
> uses hash-based or perfect filters.

Thanks for this summary (and Jason, too).  I've fallen a long way behind
NIC state-of-the-art.
 
> Most multi-queue controllers could support a kind of hash-based
> filtering for TCP/IP by adjusting the RSS indirection table.  However,
> this table is usually quite small (64-256 entries).  This means that
> hash collisions will be quite common and this can result in reordering.
> The same applies to the small table Jason has proposed for virtio-net.

But this happens on real hardware today.  Better that real hardware is
nice, but is it overkill?

And can't you reorder even with perfect matching, since prior packets
will be on the old queue and more recent ones on the new queue?  Does it
discard or requeue old ones?  Or am I missing a trick?

Thanks,
Rusty.
