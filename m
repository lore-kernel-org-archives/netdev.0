From: Sami Farin <7atbggg02@sneakemail.com>
Subject: Re: ss shows invalid ipv6 addresses
Date: Sat, 18 Dec 2004 20:30:45 +0200
Message-ID: <20041218183045.GB11231@m.safari.iki.fi>
References: <20041111230054.GD9589@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux Networking Mailing List <netdev@oss.sgi.com>
Content-Disposition: inline
In-Reply-To: <20041111230054.GD9589@m.safari.iki.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Nov 12, 2004 at 01:00:54AM +0200, Sami Farin wrote:
> thttpd does this:
> 00:43:51.115227 bind(4, {sa_family=AF_INET6, sin6_port=htons(80), inet_pton(AF_INET6, "::", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = 0 <0.000119>
> 
> which results into...
> 
> # ss -l|head -n 2 ; svc -t /service/thttpd ; sleep 2 ; ss -l|head -n 2
> Recv-Q Send-Q           Local Address:Port               Peer Address:Port   
> 0      0      ::fa38:ebe3:fe5f:fb3a:ffa6:b35e:http    ::e541:73fb:7f26:747d:b382:4122:*       
> Recv-Q Send-Q           Local Address:Port               Peer Address:Port   
> 0      0      ::81:7111:de4f:c527:81:701d:http    ::81:46b5:9313:b133:81:c2cd:*     
> 
> there are some comments about ``Cursed "v4 mapped" addresses''
> in ss.c already ;) but is it possible fix this thing so that ss
> can show some sane addresses for v4 mapped addresses?

Nothing to do with v4 mappeds, it seems.
net/ipv4/tcp_diag.c just doesn't do ipv6_addr_copy() if ipv6
support is as a module.

When I compile ipv6 support directly into kernel, ss works.

ESTAB       0      0              2002:50df:69d0::1:50011     2001:4118:10:4000::2205:silc    

-- 
