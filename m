From: Andi Kleen <ak@suse.de>
Subject: Re: looking for help with scanning of IPv6 interfaces
Date: Fri, 15 Nov 2002 20:00:51 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021115200051.A14677@wotan.suse.de>
References: <200211151738.gAFHcDwX006227@sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
Content-Disposition: inline
In-Reply-To: <200211151738.gAFHcDwX006227@sandelman.ottawa.on.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Nov 15, 2002 at 12:38:12PM -0500, Michael Richardson wrote:
> 1) Awhile ago there was a flame war about using SIOCGIFCONF/SIOCGLIFCONF
> to get lists of interfaces. This was suggested as being a bad way.
> 
> 2) bind 9.3snapshot is able to get a list of IPv4 addresses with SIOCGIFCONF,
> 
> 3) it is not able to get IPv6 addresses with SIOCGLIFCONF.
> 
> Marc Andrews, sitting next to me, asked if I knew what the offical magic
> was. Can someone point me that officially blessed way to do this?

Physical devices are read using /proc/net/dev

If you want IPv6 addresses you can read and parse /proc/net/if_inet6 

That is the old fashioned way.
 
The new fashioned one is to query them using rtnetlink. You use a RTM_GETADDR
NLM_F_REQUEST query with wildcard (NLM_F_ROOT) to get a full list.
See the netlink,rtnetlink, libnetlink manpages and iproute2 as an example. 
It is easier when you use libnetlink.

-Andi
