From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: TcpOutSegs way too optimistic (netstat -s)
Date: Fri, 14 May 2004 15:51:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40A54D73.2050108@us.ibm.com>
References: <Pine.LNX.4.58.0405150007090.8193@fcat> <Pine.LNX.4.58.0405150027230.8281@fcat>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marc Herbert <marc.herbert@free.fr>
In-Reply-To: <Pine.LNX.4.58.0405150027230.8281@fcat>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Marc Herbert wrote:

>Oups, forget the first patch, it did not tcp_enter_cwr() when
>NET_XMIT_CN.
>
>See hopefully correct patch below. Sorry for the noise.
>
>  
>

I'm not sure I agree with this patch.  Ideally, every layer should count
what it sent out, and what it drops. If a lower layer drops the segment/
packet for any reason, that is the responsibility of the lower layer to
count.  This includes the qdisc layer (a topic I will come back to).
 
If a queing discipline were counting all incoming packets, regardless
of whether they later dropped them or not, then there would be an
inconsistency between how many TCP sent out and how many
the  layer below received.

Currently, the default queing discipline statistics (dropped) are not
displayed anywhere. I have a patch that displays them in /proc/net/
along with the dev stats, which at best is a hack.

They are available if you have tc and qd support compiled, but not
via a generic statistics gathering utility  like netstat -s, a fact which
a lot of people complain about.  From previous suggestions and
conversations it was proposed that netstat -s be at least enhanced
to show qdisc drops (using netlink sockets, not /proc, although it
would be manyfold convenience to have them in /proc in some
suitable place).

I'd appreciate any thoughts/feedback on the issue :). What's the
best way to go about doing this?

thanks,
Nivedita
