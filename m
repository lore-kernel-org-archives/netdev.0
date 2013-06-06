From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next rfc V3 8/9] macvtap: add TUNSETQUEUE ioctl
Date: Thu, 06 Jun 2013 15:30:46 +0800
Message-ID: <51B03AA6.6020803@redhat.com>
References: <1370414192-5830-1-git-send-email-jasowang@redhat.com> <1370414192-5830-9-git-send-email-jasowang@redhat.com> <20130605105928.GH31830@redhat.com> <51AFFF23.20608@redhat.com> <20130606072337.GC5170@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130606072337.GC5170@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/06/2013 03:23 PM, Michael S. Tsirkin wrote:
> On Thu, Jun 06, 2013 at 11:16:51AM +0800, Jason Wang wrote:
>> > On 06/05/2013 06:59 PM, Michael S. Tsirkin wrote:
>>> > > On Wed, Jun 05, 2013 at 02:36:31PM +0800, Jason Wang wrote:
>>>> > >> This patch adds TUNSETQUEUE ioctl to let userspace can temporarily disable or
>>>> > >> enable a queue of macvtap. This is used to be compatible at API layer of tuntap
>>>> > >> to simplify the userspace to manage the queues. This is done through introducing
>>>> > >> a linked list to track all taps while using vlan->taps array to only track
>>>> > >> active taps.
>>>> > >>
>>>> > >> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>>> > >> ---
>>>> > >>  drivers/net/macvtap.c      |  133 +++++++++++++++++++++++++++++++++++++++-----
>>>> > >>  include/linux/if_macvlan.h |    4 +
>>>> > >>  2 files changed, 122 insertions(+), 15 deletions(-)
>>>> > >>
>>>> > >> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>>>> > >> index 14764cc..355e6ad 100644
>>>> > >> --- a/drivers/net/macvtap.c
>>>> > >> +++ b/drivers/net/macvtap.c

[...]
>>>>
>>> > >
>>>> > >> since we are protected by rcu read lock,
>>>> > >> +	 * we're safe here.
>>> > > I don't really understand what is this comment trying to say.
>>> > > What is protected? What is safe? safe time as what?
>> > 
>> > Will make it clear as:
>> > 
>> > "numvtaps is just a hint, even if the number of active taps were reduced
>> > in the same tap, since the tap pointers were protected by rcu read lock,
>> > they are safe even if some of them were being removed"
> I think I see.  I think what you really meant is two things:
> - near macvtap_forward:
>  /* called under rcu read lock */
> - and here: 
> /*
>  * Access to taps array is protected by rcu, but access to numvtaps
>  * isn't. Below we use it to lookup a queue, but treat it as a hint
>  * and validate that the result isn't NULL - in case we are
>  * racing against queue removal.
>  */

Yes, will correct the comments.

Thanks
