From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: Function to read IP address in dot format
Date: Mon, 11 Apr 2005 11:07:46 -0300
Message-ID: <39e6f6c7050411070779ddcb07@mail.gmail.com>
References: <20050411060510.12208.qmail@web52201.mail.yahoo.com>
Reply-To: acme@conectiva.com.br
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux lover <linux_lover2004@yahoo.com>
In-Reply-To: <20050411060510.12208.qmail@web52201.mail.yahoo.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Apr 11, 2005 3:05 AM, linux lover <linux_lover2004@yahoo.com> wrote:
> 
> Hello,
>           what is the function to read IP address in
> kernel code as human readable dot quad format? IP
> address are unsigned int's in ip.h file as
>         __u32   saddr;
>         __u32   daddr;
>          In ip_build_xmit ip header gets IP addresses
> from rtable struct as
> iph->saddr=rt->rt_src;
> iph->daddr=rt->rt_dst;
>            Now if i want to know to which ip current
> packet is being sent i am using printks but it prints
> iph->saddr in int format not in user readable format.
> how to do that?
> regards,

Use NIPQUAD, as in the example below:

        printk(KERN_DEBUG "dccp rx: packet=%s, "
                          "source=%u.%u.%u.%u@%d, "
                          "dest=%u.%u.%u.%u@%d\n",
               dccp_packet_name(dh->dccph_type),
               NIPQUAD(skb->nh.iph->saddr),
               ntohs(dh->dccph_sport),
               NIPQUAD(skb->nh.iph->daddr),
               ntohs(dh->dccph_dport));

- Arnaldo
