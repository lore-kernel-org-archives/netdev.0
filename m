From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: SKB paged fragment lifecycle on receive
Date: Fri, 24 Jun 2011 15:48:21 -0700
Message-ID: <4E051435.8080302@goop.org>
References: <1308930202.32717.144.camel@zakaz.uk.xensource.com>	
	<4E04C961.9010302@goop.org>
	<1308955477.5807.8.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	xen-devel <xen-devel@lists.xensource.com>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <1308955477.5807.8.camel@dagon.hellion.org.uk>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On 06/24/2011 03:44 PM, Ian Campbell wrote:
> One problem with this is that some functions (__pskb_pull_tail) drop the
> ref count and then remove the page from the skb's fraglist. So by the
> time the destructor is called you have lost the page and cannot do the
> refcount checking.
>
> I suppose we could keep a queue of _all_ pages we ever put in an SKB
> which we poll.

Right, that seems like the only way to make sure we don't lose anything.

>  We could still check for pages with count==1 in the
> destructor. Apart from the other issues with the destructor not being
> copied over clone etc which would cause us to fall-back to polling the
> queue more often than not I reckon.

Yeah, sounds like it.

>> That said, I think an event-based rather than polling based mechanism
>> would be much more preferable.
> Absolutely.

>From what Eric and David were saying, it seems we don't really have any
other workable options.

    J
