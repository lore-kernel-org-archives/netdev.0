From: DHAJOGLO <DHAJOGLO@smumn.edu>
Subject: cc: Re: skb configured but can't get data allocated
Date: Wed, 12 Sep 2007 18:41:41 -0500
Message-ID: <200709122341418320c60701@mail.smumn.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: kernelnewbies@nl.linux.org, macnish@gmail.com,
	netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smumn.edu ([140.190.136.243]:2775 "EHLO mail.smumn.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754363AbXILXlm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 19:41:42 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To All, Thanks for the help.  I ended up adding my data packet after the ip headers and then updated the IP length:

 /* Allocate space for our exp_packet data payload and set the data */
        d_out = (struct exp_packet *)skb_put(skb,sizeof(struct exp_packet));
        d_out->headbits = (reply<<4) & 0xF0;
        d_out->sequence = pkthr.m_seq;
        d_out->payload = htons(pkthr.p_hash);

        /* adjust the total length of this IP packet */
        iplen = skb->tail - (unsigned char *)skb->nh.iph;
        iph->tot_len = htons(iplen);
        ip_send_check(iph);

This is my first venture into the kernel!

On Wednesday, September 12, 2007  3:12 PM, Vlad Yasevich wrote:
>
>Date: Wed, 12 Sep 2007 16:12:37 -0400
>From: Vlad Yasevich
>To: DHAJOGLO <DHAJOGLO@smumn.edu>
>Subject: Re: skb configured but can't get data allocated
>
>You may want to read this page:
>http://vger.kernel.org/~davem/skb.html
>
>You will then see you problem.
>
>Essentially, you are writing your data into an
>area that is never sent.
>
>What you are end up is this:
>
>---------------------------------------------
>| your data| space | ll-header | IPv4 header|
>---------------------------------------------
>
>-vlad



