From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPV6_V6ONLY Support, v2 (is Re: [PATCH] IPv6: Allow Both
 IPv6 and IPv4 Sockets on the Same Port)
Date: Wed, 23 Oct 2002 13:15:26 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210231312070.28208-100000@netcore.fi>
References: <20021023.190131.67057125.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: kuznet@ms2.inr.ac.ru, <davem@redhat.com>, <netdev@oss.sgi.com>,
   <usagi@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20021023.190131.67057125.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Oct 2002, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> In article <Pine.LNX.4.44.0210231031540.26788-100000@netcore.fi> (at Wed, 23 Oct 2002 10:36:19 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:
> 
> > Does Bind 9.2.1 work this so that it can receive packets, when IPv6 is
> > also enabled, from IPv4 addresses using TCP without
> > 'match-mapped-addresses yes', or is that a separate problem?
> 
> Bind9 trys to bind :: and all ipv4 addresses on the node.

Yes, but binding those IPv4 addresses _for TCP_ failed after binding to 
::, at least previously.  That worked e.g. on BSD.  Does that work now, 
too?

I.e. I have two boxes, both running Bind 9.2.1.  Linux gives:

$ netstat -an | grep :53
tcp        0      0 :::53                   :::*                    LISTEN      
udp        0      0 193.94.160.1:53         0.0.0.0:*                           
udp        0      0 127.0.0.1:53            0.0.0.0:*                           
udp        0      0 :::53                   :::*    

and BSD gives:

# netstat -an | grep .53
tcp6       0      0  ::1.953                *.*                    LISTEN
tcp4       0      0  127.0.0.1.953          *.*                    LISTEN
tcp4       0      0  127.0.0.1.53           *.*                    LISTEN
tcp4       0      0  193.166.4.206.53       *.*                    LISTEN
tcp4       0      0  193.166.187.10.53      *.*                    LISTEN
tcp6       0      0  *.53                   *.*                    LISTEN
udp4       0      0  127.0.0.1.53           *.*                    
udp4       0      0  193.166.4.206.53       *.*                    
udp4       0      0  193.166.187.10.53      *.*                    
udp6       0      0  *.53                   *.*

Will this work too?

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
