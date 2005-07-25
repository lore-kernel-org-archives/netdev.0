From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netlink connector
Date: Mon, 25 Jul 2005 23:28:53 +0400
Message-ID: <20050725192853.GA30567@2ka.mipt.ru>
References: <20050723125427.GA11177@rama> <20050723091455.GA12015@2ka.mipt.ru>
	<20050724.191756.105797967.davem@davemloft.net>
	<Lynx.SEL.4.62.0507250154000.21934@thoron.boston.redhat.com>
	<20050725070603.GA28023@2ka.mipt.ru> <42E4F800.1010908@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Andrew Morton <akpm@osdl.org>, Harald Welte <laforge@netfilter.org>,
	netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42E4F800.1010908@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 25, 2005 at 04:32:32PM +0200, Patrick McHardy (kaber@trash.net) wrote:
> Evgeniy Polyakov wrote:
> >On Mon, Jul 25, 2005 at 02:02:10AM -0400, James Morris 
> >(jmorris@redhat.com) wrote:
> >
> >>On Sun, 24 Jul 2005, David S. Miller wrote:
> >>
> >>>From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> >>>Date: Sat, 23 Jul 2005 13:14:55 +0400
> >>>
> >>>
> >>>>Andrew has no objection against connector and it lives in -mm
> >>>
> >>>A patch sitting in -mm has zero significance.
> >
> >That is why I'm asking netdev@ people again...
> 
> If I understand correctly it tries to workaround some netlink
> limitations (limited number of netlink families and multicast groups)
> by sending everything to userspace and demultiplexing it there.
> Same in the other direction, an additional layer on top of netlink
> does basically the same thing netlink already does. This looks like
> a step in the wrong direction to me, netlink should instead be fixed
> to support what is needed.

Not only it.
The main _first_ idea was to simplify userspace mesasge handling as much
as possible.
In first releases I called it ioctl-ng - any module that want ot
communicate with userspace in the way ioctl does, 
requires skb allocation/freeing/handling.
Does RTC driver writer need to know what is the difference between
shared and cloned skb? Should kernel user of such message bus
have to know about skb at all?
With char device I only need to register my callback - with kernel
connector it is the same, but allows to use the whole power of netlink,
especially without nice ioctl features like different pointer size 
in userspace and kernelspace.
And number of free netlink sockets is _very_ small, especially
if allocate new one for simple notifications, which can be easily done
using connector.
No need to allocate skb, no need to know who are those monsters in
header and so on.

And netlink can be extended to support it - netlink is a transport
protocol, it should not care about higher layer message handling,
connector instead will deliver message to the end user in a very
convenient form.

P.S. I've removed netdev@redhat.com - please do not add subscribers-only
private mail lists.

-- 
	Evgeniy Polyakov
