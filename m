From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net 2/2] virtio-net: refill only when device is up during
	setting queues
Date: Tue, 15 Oct 2013 11:15:06 +0800
Message-ID: <525CB33A.4080103@redhat.com>
References: <1381744595-26881-1-git-send-email-jasowang@redhat.com>
	<1381744595-26881-2-git-send-email-jasowang@redhat.com>
	<20131014110951.GG30954@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20131014110951.GG30954@redhat.com>
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

On 10/14/2013 07:09 PM, Michael S. Tsirkin wrote:
> On Mon, Oct 14, 2013 at 05:56:35PM +0800, Jason Wang wrote:
>> > We used to schedule the refill work unconditionally after changing the
>> > number of queues. This may lead an issue if the device is not
>> > up. Since we only try to cancel the work in ndo_stop(), this may cause
>> > the refill work still work after removing the device. Fix this by only
>> > schedule the work when device is up.
>> > 
>> > The bug were introduce by commit 9b9cd8024a2882e896c65222aa421d461354e3f2.
>> > (virtio-net: fix the race between channels setting and refill)
>> > 
>> > Cc: Rusty Russell <rusty@rustcorp.com.au>
>> > Cc: Michael S. Tsirkin <mst@redhat.com>
>> > Signed-off-by: Jason Wang <jasowang@redhat.com>
> It bothers me that we look at the flag without any
> locks here.
> I think we'll need to take the rtnl lock at least
> on restore.
>

True, will post v2.
