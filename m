From: Derek Fawcus <dfawcus@cisco.com>
Subject: Re: [PATCH] IPv6: Fix Prefix Length of Link-local Addresses
Date: Thu, 10 Oct 2002 02:11:54 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021010021154.G8102@edi-view1.cisco.com>
References: <20021009.162438.82081593.davem@redhat.com> <uu1jv9o3j.wl@sfc.wide.ad.jp> <20021009.164504.28085695.davem@redhat.com> <ur8ez9n8d.wl@sfc.wide.ad.jp> <20021010010439.C8102@edi-view1.cisco.com> <uptuj9mkq.wl@sfc.wide.ad.jp> <20021010012108.E8102@edi-view1.cisco.com> <uofa39lm9.wl@sfc.wide.ad.jp> <20021010014237.F8102@edi-view1.cisco.com> <un0pn9knb.wl@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Yuji Sekiya <sekiya@sfc.wide.ad.jp>
In-Reply-To: <un0pn9knb.wl@sfc.wide.ad.jp>; from sekiya@sfc.wide.ad.jp on Thu, Oct 10, 2002 at 09:56:24AM +0900
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 10, 2002 at 09:56:24AM +0900, Yuji Sekiya wrote:
> 
> I can underdtand there is no interoperability issue with cisco box
> (with /10 link-local prefix ?) and USAGI kernel(with /64 link-local
> prefix). :-)

Mind it's interesting that the above currently works.  I suspect that
this is because the ping was originated on the cisco box,  and hence
ND was triggered,  with the linux box probably gleaning info from the
NS to create a STALE entry.  That STALE entry would then probably have
been probed to get a REACHABLE entry.

What happens if you clear the ND entries (on both boxes),  swap the
link local addresses,  then ping from the Linux box to the cisco box?

I suspect that the ping will fail.  As ND will never be triggered,  and
hence the host routes will not be created.

Another alternative would be if one was say fe80:1910::10 and the other
say fe80:2010::20,  that would probably fail with the ping originated
from the linux end,  but I'm not sure if the linux box would respond
when the ping was originated from the cisco end.  Assuming my guess
about the gleaning above is correct,  it probably will.

DF
