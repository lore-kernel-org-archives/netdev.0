From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] flow-dissector: Fix alignment issue in
 __skb_flow_get_ports
Date: Mon, 13 Oct 2014 08:32:10 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174C987C@AcuExch.aculab.com>
References: <5437F7CB.5010101@redhat.com>
	<1412954973.9362.11.camel@edumazet-glaptop2.roam.corp.google.com>
	<54380E49.5050504@redhat.com>
 <20141010.135851.1743803688676076555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49533 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752052AbaJMIeD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 04:34:03 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 07864-08 for <netdev@vger.kernel.org>;
 Mon, 13 Oct 2014 09:33:53 +0100 (BST)
In-Reply-To: <20141010.135851.1743803688676076555.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller
> From: Alexander Duyck <alexander.h.duyck@redhat.com>
> Date: Fri, 10 Oct 2014 09:50:17 -0700
> 
> > If I just use get_unaligned that is pretty easy in terms of cleanup
> > for the ports and IPv4 addresses, the IPv6 will still be a significant
> > hurdle to overcome though.
> 
> Actually, it's not that simple.
> 
> When the compiler sees things like "th->doff" it will load the 32-bit
> word that 4-bit field contains and extract the value using shifts and
> masking.
> 
> So we might need to sprinkle a "attribute((packed))" here and there
> to make it work.

Marking a structure 'packed' forces the compiler to generate byte accesses.
It is enough to mark the 32bit members with __attribute__((aligned(2)))
(or use a typedef for u32 that includes that attribute).
Then the compiler will use 16bit accesses for that field.

	David
