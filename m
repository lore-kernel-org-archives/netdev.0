From: "David S. Miller" <davem@davemloft.net>
Subject: Re: PPP-over-L2TP kernel support, patch for review
Date: Tue, 7 Sep 2004 15:56:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040907155657.2ab6a4bb.davem@davemloft.net>
References: <1094471956.413c5114de2d7@www.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kleptog@svana.org
Return-path: <netdev-bounce@oss.sgi.com>
To: James Chapman <jchapman@katalix.com>
In-Reply-To: <1094471956.413c5114de2d7@www.katalix.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon,  6 Sep 2004 12:59:16 +0100
James Chapman <jchapman@katalix.com> wrote:

> I'm working towards having this driver integrated into the kernel
> tree. Comments?

Only two major comments:

1) Uses own linked list implementations.  Please use
   linux/list.h interfaces for this.

2) Does this:

 struct sockaddr_pppox { 
        sa_family_t     sa_family;            /* address family, AF_PPPOX */ 
        unsigned int    sa_protocol;          /* protocol identifier */ 
        union{ 
                struct pppoe_addr       pppoe; 
+               struct pppol2tp_addr    pppol2tp;
        }sa_addr; 
 }__attribute__ ((packed)); 

   Change the size of sockaddr_pppox on any platform?  If so, you'll
   break pppox userspace with this change so we'd need find another
   way to do it.

Thanks.
