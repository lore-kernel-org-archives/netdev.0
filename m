From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFT] Re: Fw: Nasty Oops in 2.6.0-test6 bind/SO_REUSEADDR
Date: Sat, 11 Oct 2003 12:56:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031011125656.322bd0ab.davem@redhat.com>
References: <20031008133345.49f71991.davem@redhat.com>
	<20031010023644.GA8365@conectiva.com.br>
	<20031010032244.GB8365@conectiva.com.br>
	<20031009211437.2cf87a4f.davem@redhat.com>
	<20031010154052.GA11366@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, dmerillat@sequiam.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20031010154052.GA11366@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 10 Oct 2003 12:40:52 -0300
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> ipv6_rcv_saddr_equal, look at this:
> 
>         if (sk2->sk_family == AF_INET6 &&
>             !ipv6_addr_cmp(&np->rcv_saddr,
>                            (sk2->sk_state != TCP_TIME_WAIT ?
>                             &inet6_sk(sk2)->rcv_saddr :
>                             &tcptw_sk(sk)->tw_v6_rcv_saddr)))
>                                       ^^
>                                       ^^
> shouldn't the tcp_tw_sk(sk) be tcp_tw_sk(sk2)?

Yes.

> And in this function we have the guard against it being a tcp_tw_bucket, but
> not in all places...

It does guard in this spot, that's why it is checking the
sk_state value.
