From: Neil Horman <nhorman@redhat.com>
Subject: Re: require packet path at device layer
Date: Fri, 07 Jan 2005 08:05:51 -0500
Message-ID: <41DE892F.5030206@redhat.com>
References: <72c6e3790501070020755ffacf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux lover <linux.lover2004@gmail.com>
In-Reply-To: <72c6e3790501070020755ffacf@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

linux lover wrote:
> Hello,
>     Can anybody provide me how packet control is transferred from
> netif_rx to netif_receive_skb function.
> regards,
> linux.lover
> -
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Believe its done directly in netif_rx, which calls:
netif_rx_schedule(&queue->blog_dev)
The poll routine for blog_dev which gets set in net_dev_init is called 
process_backlog, which takes packets queued from netif_rx and calls 
netif_receive_skb with them

HTH
Neil

-- 
/***************************************************
  *Neil Horman
  *Software Engineer
  *Red Hat, Inc.
  *nhorman@redhat.com
  *gpg keyid: 1024D / 0x92A74FA1
  *http://pgp.mit.edu
  ***************************************************/
