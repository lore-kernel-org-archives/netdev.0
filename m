From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] inet_opt space saving?
Date: Thu, 16 Sep 2004 13:44:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916134405.4093e659.davem@redhat.com>
References: <20040914151232.115c3eca@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040914151232.115c3eca@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 14 Sep 2004 15:12:32 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> It looks like there are lots of wasted bytes in the inet information
> per socket. Does this look right? 

I see one error at least.

> +				cmsg_flags: 4,

There are 5 bits, not 4.

#define IP_CMSG_PKTINFO		1
#define IP_CMSG_TTL		2
#define IP_CMSG_TOS		4
#define IP_CMSG_RECVOPTS	8
#define IP_CMSG_RETOPTS		16

This is also the number of right shifts, plus one, made
by ip_cmsg_recv().

The rest of your transformations look perfectly fine.
