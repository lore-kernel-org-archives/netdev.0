From: Rabeeh Khoury <rabeeh@galileo.co.il>
Subject: Re: Linux IP stack on kernel 2.4.18
Date: Mon, 03 Jun 2002 11:40:11 +0300
Sender: owner-netdev@oss.sgi.com
Message-ID: <adp779$ne7$2@main.gmane.org>
References: <3CF9DDD0.3080809@galileo.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Rabeeh Khoury <rabeeh@galileo.co.il>
List-Id: netdev.vger.kernel.org

I fixed the problems. I'm replying for the record of the mailing list.

Rabeeh Khoury wrote:

> Hi All,
>
> I'm using kernel 2.4.18 and developing an ethernet network interface 
> driver.
> I have two problems that if you may consult me how to solve them -
>
> 1.. How can I adjust the throttling parameter of the IP stack not to 
> drop any packet ? Meantime the IP stack routes 55k packets/sec and all 
> the other it just drops (I can see them by the result of netif_rx). 

echo 50000 > /proc/sys/net/core/netdev_max_backlog

This puts the throttling parameter of the IP stack to 50000, instead of 
300 which is the defaul in kernel 2.4.18 (the default is set in 
net/core/dev.c with the variable 'int netdev_max_backlog = 300;')

>
> 2.. Routing jumbo packets through IP stack - I send 9K packets in size 
> and IP stack routes the packets but by sending 1K packets in size ! is 
> this possible ? I tripple checked the device driver on receive and 
> transmit and it's ok. Do you know what is the problem ? 

The HW I'v used that generates jumbo packets has put a wrong 
total_length field in the IP header, which made IP stack remove a large 
chunck of the packet. The relevant code that removes the chunck is in 
net/ipv4/ip_input.c -

                /* Our transport medium may have padded the buffer out. 
Now we know it
                 * is IP we can trim to the true length of the frame.
                 * Note this now means skb->len holds ntohs(iph->tot_len).
                 */
                if (skb->len > len) {
                      __pskb_trim(skb, len);
                        if (skb->ip_summed == CHECKSUM_HW)
                                skb->ip_summed = CHECKSUM_NONE;
                }

>
>
>
> Thank you alot,
> Rabeeh
>
>
>
>
