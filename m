From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-next V3] net: dynamic ingress_queue allocation
Date: Sun, 03 Oct 2010 09:10:34 -0400
Message-ID: <1286111434.3812.208.camel@bigi>
References: <1285689517.3154.76.camel@edumazet-laptop>
	 <20100928180447.GA1880@del.dom.local> <1285757817.3561.2.camel@bigi>
	 <1285887509.2705.33.camel@edumazet-laptop> <1285933506.3553.176.camel@bigi>
	 <1285941388.2641.175.camel@edumazet-laptop>
	 <20101002093255.GA2049@del.dom.local>
	 <1286035915.2582.2472.camel@edumazet-laptop>
	 <20101003094221.GA2028@del.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:62711 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639Ab0JCNKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Oct 2010 09:10:37 -0400
Received: by qwh6 with SMTP id 6so2475483qwh.19
        for <netdev@vger.kernel.org>; Sun, 03 Oct 2010 06:10:37 -0700 (PDT)
In-Reply-To: <20101003094221.GA2028@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-10-03 at 11:42 +0200, Jarek Poplawski wrote:

> > 
> > To avoid a NULL dereference some lines later.
> > Do I have a guarantee its not NULL here ?
> 
> Do you have any scenario for NULL here? ;-)

This is why i called this part clever earlier ;-> It is 
clever. There are several scenarios (i attempted to represent them
in the tests that Eric run):

1) ingress qdisc has been compiled in
flags & TCQ_F_INGRESS is true
a) user trying to add ingress qdisc first time
then q is null, new is not null and this would work
b) user trying to delete already added qdisc
then q is not null, new is null 

2) ingress qdisc not compiled in
Repeat #1a above, and Eric's check will bail out ..

The one thing that may have been useful is to also try
a "replace" after #1a and maybe after #2

cheers,
jamal

