From: John Partridge <johnip@sgi.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 08 Oct 2003 14:02:57 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F845F61.9080002@sgi.com>
References: <3F844578.40306@sgi.com>	<20031008101046.376abc3b.davem@redhat.com>	<3F844EF9.9090901@sgi.com> <20031008112657.2adddeb6.davem@redhat.com>
Reply-To: johnip@sgi.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031008112657.2adddeb6.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

OK, fair enough, you mean like :-

#if defined(__ia64__)
	if (len > RX_COPY_THRESHOLD && tp->rx_offset == 2) {
#else
	if (len > RX_COPY_THRESHOLD) {
#endif



David S. Miller wrote:
> On Wed, 08 Oct 2003 12:52:57 -0500
> John Partridge <johnip@sgi.com> wrote:
> 
> 
>>Not too much different
> 
> 
> The problem is that your change is arch-dependant yet you make it
> run on all platforms.
> 
> On x86 we don't want to do what your change is doing, the unaligned
> accesses are cheap enough.
> 
> We need to abstract this, probably in the same way it is done in
> the Tulip and other drivers which have similar issues.

-- 
John Partridge

Silicon Graphics Inc
Tel:  651-683-3428
Vnet: 233-3428
E-Mail: johnip@sgi.com
