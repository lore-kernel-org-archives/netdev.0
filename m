From: "David S. Miller" <davem@redhat.com>
Subject: Re: (usagi-core 11926) Re: [PATCH] IPv6 IPsec support
Date: Wed, 19 Feb 2003 13:27:44 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030219.132744.105180654.davem@redhat.com>
References: <20030219134850.5f203ea7.Kazunori.Miyazawa@jp.yokogawa.com>
	<20030218.233301.98333082.davem@redhat.com>
	<20030219233915.130a26e3.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org, Kazunori.Miyazawa@jp.yokogawa.com,
   netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: kazunori@miyazawa.org
In-Reply-To: <20030219233915.130a26e3.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Kazunori MIyazawa <kazunori@miyazawa.org>
   Date: Wed, 19 Feb 2003 23:39:15 +0900
   
   > 3) I noticed comment above transformation from
   >    explicit dst->output() call to dst_output().
   > 
   >    It is not IPSEC issue, rather I believe that entire tree should
   >    have this conversion eventually.  The concept of stackable
   >    destination cache entries is a generic one.
   > 
   
   Please let me understand. I think dst->output calls each dst
   output routine chains but those could not process the return value 
   NET_XMIT_BYPASS returned from ah and/or esp.
   Is this out of scope of IPsec?

Not really.  Stackable destinations are a powerful concept.

For example, we could reimplement IPIP processing using this.
In this way, IP tunnels can become stacked destinations.

Another application of stackable destinatins could be something
like CIPE.

Please understand what NET_XMIT_BYPASS means, which is "please
continue to invoke input/output method, I have placed new dst in skb"

I will apply the patch from Yoshfuji which makes the transformations.
