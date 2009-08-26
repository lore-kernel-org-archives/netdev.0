From: Chris Ross <chris@compilednetworks.com>
Subject: skb_copy/clone question
Date: Wed, 26 Aug 2009 10:07:59 -0500
Message-ID: <17cd85320908260807k78a0353ha82da7f8dbc34ec@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f204.google.com ([209.85.223.204]:55727 "EHLO
	mail-iw0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbZHZPH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 11:07:57 -0400
Received: by iwn42 with SMTP id 42so102295iwn.33
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2009 08:07:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a driver that generate N packets to send for every 1 it
receives, similar to a bridge in functionality. I need to insert a
slightly different header for each output packet. My current approach
which is causing some issues is ..

send_packet(struct sk_buff* skb)
{
  if (skb_cow_head(skb, some_val) < 0)
    goto error_condition;

  .. insert header ..

  .. set skb->dst, and ident ..

  ip_local_out(skb)
}

// main section
for each egress packet
{
  // skb->len is always > 0 here
  if ((tskb = pskb_copy(skb, GFP_ATOMIC)) == NULL)
    goto error_condition;

  // tskb->len seems to be 0 here
  send_packet(tskb)
}

I've played with both pskb_copy and skb_copy and both seem to result
in a packet with len of 0. I was expecting skb->len to be equivalent
to tskb->len. I am running 2.6.29, any pointers would be appreciated.

thanks,

-chris
