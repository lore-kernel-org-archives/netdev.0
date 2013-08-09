From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] macvtap: fix two races
Date: Fri, 09 Aug 2013 10:41:07 -0700
Message-ID: <1376070067.20509.1.camel@edumazet-glaptop>
References: <20130807164319.20aa2333@thhw500>
	  <1375889211.4004.28.camel@edumazet-glaptop>
	  <20130808102551.6aa47852@thhw500>
	  <1375968072.4004.92.camel@edumazet-glaptop>
	  <20130808155634.239dbc2d@thhw500>
	 <1375974374.4004.103.camel@edumazet-glaptop> <520523DA.1000400@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Huth <thuth@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35643 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758369Ab3HIRlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 13:41:09 -0400
Received: by mail-pa0-f53.google.com with SMTP id lb1so5194062pab.26
        for <netdev@vger.kernel.org>; Fri, 09 Aug 2013 10:41:09 -0700 (PDT)
In-Reply-To: <520523DA.1000400@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-09 at 13:16 -0400, Vlad Yasevich wrote:

> I was looking at this a bit more and I think this call to 
> macvlan_count_rx() is double counting the packets.
> 
> In macvlan_handle_frame(), we call macvlan_count_rx() after we call
> vlan->receive().  For macvtap, receive() function is essentially 
> macvtap_forward() which just tacks the data onto the queue.
> 
> Then, the above code counts the data again as we pull it off the queue
> socket queue to give to the user.

Hmm, it seems a different issue, and probably needs a patch on its own.

When was this problem added ?
