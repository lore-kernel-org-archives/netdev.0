From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] TCP acts like it is always out of memory.
Date: Thu, 1 Jul 2004 22:32:25 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040702013225.GA24707@conectiva.com.br>
References: <32886.63.170.215.71.1088564087.squirrel@www.osdl.org> <20040629222751.392f0a82.davem@redhat.com> <20040630152750.2d01ca51@dell_ss3.pdx.osdl.net> <20040630153049.3ca25b76.davem@redhat.com> <20040701133738.301b9e46@dell_ss3.pdx.osdl.net> <20040701140406.62dfbc2a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040701140406.62dfbc2a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Thu, Jul 01, 2004 at 02:04:06PM -0700, David S. Miller escreveu:
> On Thu, 1 Jul 2004 13:37:38 -0700
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > Current 2.6.7 tree acts as if it is alway under memory pressure because
> > a recent change did a s/tcp_memory_pressure/tcp_prot.memory_pressure/.
> > The problem is tcp_prot.memory_pressure is a pointer, so it is always non-zero!
> > 
> > Rather than using *tcp_prot.memory_pressure, just go back to looking at
> > tcp_memory_pressure.
> 
> Hehe, applied thanks Stephen.

:-) Thanks Stephen for the fix, this was a leftover of the conversion of
the memory pressure members in struct proto to pointers, to cover the case
pointed out by David related to the ipv6_mapped functionality in the
1.1722.122.23 changeset, (i.e.  tcp_prot and tcpv6_prot having to share the
same accounting variables), I forgot to convert all places where the
tcp_prot.memory_pressure memory is used, the fix is exactly what I should
have done. Due to family health problems I was unable to promply fix this
thinko, so, again, thank you very much.

Best Regards,

- Arnaldo
