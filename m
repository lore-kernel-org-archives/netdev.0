From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [PATCH 2.6.12-rc4] IPv4/IPv6: UDP Large Send Offload feature
Date: Fri, 27 May 2005 09:32:00 -0700
Message-ID: <000a01c562d9$9b661130$3910100a@pc.s2io.com>
References: <20050526.164217.45745005.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <jgarzik@pobox.com>, <netdev@oss.sgi.com>,
        <raghavendra.koushik@neterion.com>, <leonid.grossman@neterion.com>,
        <ananda.raju@neterion.com>, <rapuru.sriram@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'David S. Miller'" <davem@davemloft.net>
In-Reply-To: <20050526.164217.45745005.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,
Thanks for the quick feedback.
At that time when we considered using skb_shinfo(skb)->fraglist,
it contained fragments of MTU size. So, for a 60k udp datagram 
and 1500 MTU we will have 60k/1500 = 45 fragments which is
more than MAX_SKB_FRAGS(18).

However we will relook at fraglist for the possibility of increasing
frag size to >MTU.

Thanks,
Ravi 

-----Original Message-----
From: David S. Miller [mailto:davem@davemloft.net]
Sent: Thursday, May 26, 2005 4:42 PM
To: ravinandan.arakali@neterion.com
Cc: jgarzik@pobox.com; netdev@oss.sgi.com;
raghavendra.koushik@neterion.com; leonid.grossman@neterion.com;
ananda.raju@neterion.com; rapuru.sriram@neterion.com
Subject: Re: [PATCH 2.6.12-rc4] IPv4/IPv6: UDP Large Send Offload
feature



sock_append_data() seems like a lot of wasted work.

We already pass around the fragmented SKB as a list chained by
skb_shinfo(skb)->fraglist, just pass this thing to the device and in
this way you'll avoid all of that work sock_append_data() does
entirely.

Or is there a reason you did not implement it this
way?

This is one of the uses the skb_shinfo(skb)->fraglist was intended
for.

IN FACT, this fragmentation offload you are implementing here is what
the feature bit NETIF_F_FRAGLIST was meant to indicate.
