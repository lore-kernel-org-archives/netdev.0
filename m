From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Fri, 24 Sep 2004 13:20:02 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924032002.GA6384@gondor.apana.org.au>
References: <20040920025802.GA11567@gondor.apana.org.au> <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net> <20040922000503.GA13218@gondor.apana.org.au> <4150E7E5.2000001@eurodev.net> <1095821624.1045.6.camel@jzny.localdomain> <20040922034634.GA14928@gondor.apana.org.au> <1095852956.1048.47.camel@jzny.localdomain> <20040923120520.GA32624@gondor.apana.org.au> <1095994597.1045.26.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1095994597.1045.26.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 23, 2004 at 10:56:37PM -0400, jamal wrote:
>
> > What's wrong with the default sizes? If you decrease it far enough
> > of course it's going to overflow.
> 
> The idea is to reproduce the overun ;->

OK, I've just tried 4096 and nothing:

21619 socket(PF_NETLINK, SOCK_RAW, 0)   = 3
21619 setsockopt(3, SOL_SOCKET, SO_SNDBUF, [32768], 4) = 0
21619 setsockopt(3, SOL_SOCKET, SO_RCVBUF, [4096], 4) = 0
...
21619 recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, sa_data="\0\0\0\0\0\0\0\0\
0\0\0\0\0\0"}, msg_iov(1)=[{"\30\16\0\0002\0\2\0\366@SAsT\0\0\0 00\4\16\1\0p\0\0
\0\24"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 3608
21619 write(1, "\n\taction order 0: gact action dr"..., 4096) = 4096
21619 recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, sa_data="\0\0\0\0\0\0\0\0\
0\0\0\0\0\0"}, msg_iov(1)=[{"\30\16\0\0002\0\2\0\366@SAsT\0\0\0 00\4\16\1\0p\0\0
\0\24"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 3608
21619 write(1, "0\n\t index 19312 ref 1 bind 0\n \n\t"..., 4096) = 4096
21619 recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, sa_data="\0\0\0\0\0\0\0\0\
0\0\0\0\0\0"}, msg_iov(1)=[{"\30\16\0\0002\0\2\0\366@SAsT\0\0\0 00\4\16\1\0p\0\0
\0\24"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 3608
21619 recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, sa_data="\0\0\0\0\0\0\0\0\
0\0\0\0\0\0"}, msg_iov(1)=[{"\30\16\0\0002\0\2\0\366@SAsT\0\0\0 00\4\16\1\0p\0\0
\0\24"..., 16384}], msg_controllen=0, msg_flags=0}, 0) = 3608
21619 write(1, "action drop\n\t random type none p"..., 4096) = 4096

> $TC actions add \
>  action drop index 1
>  action drop index 2 
>  action drop index 3 ...
> 
> Do 10 a time in the for loop and should be roughly 10 times as fast

Cool, didn't know that.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
