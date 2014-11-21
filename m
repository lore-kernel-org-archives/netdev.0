From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v2 net 1/2] drivers/net: Disable UFO through virtio
Date: Fri, 21 Nov 2014 09:47:18 +0800
Message-ID: <546E99A6.5090803@redhat.com>
References: <1414693592.16849.61.camel@decadent.org.uk>	<1414693632.16849.62.camel@decadent.org.uk>
	<20141119091455.GA26036@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Hannes Frederic Sowa <hannes@stressinduktion.org>,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, Ben Hutchings <ben@decadent.org.uk>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20141119091455.GA26036@redhat.com>
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

On 11/19/2014 05:14 PM, Michael S. Tsirkin wrote:
> On Thu, Oct 30, 2014 at 06:27:12PM +0000, Ben Hutchings wrote:
>> > IPv6 does not allow fragmentation by routers, so there is no
>> > fragmentation ID in the fixed header.  UFO for IPv6 requires the ID to
>> > be passed separately, but there is no provision for this in the virtio
>> > net protocol.
>> > 
>> > Until recently our software implementation of UFO/IPv6 generated a new
>> > ID, but this was a bug.  Now we will use ID=0 for any UFO/IPv6 packet
>> > passed through a tap, which is even worse.
>> > 
>> > Unfortunately there is no distinction between UFO/IPv4 and v6
>> > features, so disable UFO on taps and virtio_net completely until we
>> > have a proper solution.
>> > 
>> > We cannot depend on VM managers respecting the tap feature flags, so
>> > keep accepting UFO packets but log a warning the first time we do
>> > this.
>> > 
>> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
>> > Fixes: 916e4cf46d02 ("ipv6: reuse ip6_frag_id from ip6_ufo_append_data")
> There's something I don't understand here. I see:
>
>         NETIF_F_UFO_BIT,                /* ... UDPv4 fragmentation */
>
> this comment is wrong then?

Looks wrong, at least ufo6 depends check this bit in ip6_output.c
