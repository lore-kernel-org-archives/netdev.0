From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [QUESTION] nf_defrag_ipv4: what does net/ipv4/netfilter/nf_defrag_ipv4.c
 used for?
Date: Fri, 12 Jun 2009 14:01:40 +0800
Message-ID: <4A31EF44.90107@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53616 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751692AbZFLGFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jun 2009 02:05:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
  Can someome tell me what does net/ipv4/netfilter/nf_defrag_ipv4.c
used for? When I looking the source of nf_defrag_ipv4, I found something
strange.

  If NF_DEFRAG_IPV4 is not selected when compile kernel, the normal
path of ipv4 fragment process is like this:

                      ____________________
 IPv4 Fragment  ---> |  NF_IP_PRE_ROUTING |--> routing input -> ip_defrag()
                     |____________________|

 But is NF_DEFRAG_IPV4=y, the ipv4 fragment process is like this:
 
                      ____________________
 IPv4 Fragment  ---> |  NF_IP_PRE_ROUTING | -> ip_defrag()
                     |____________________|

The only thing nf_defrag_ipv4 do is not select input route.

This cause problem that if the defragment is timeout, the ICMP fragment
timeout can not be sent out, because the input skb has no route
information.

void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
{
      ...
      struct rtable *rt = skb_in->rtable;
      ...
      if (!rt)
          goto out;           <--- fail in this step
      ...
}


Any idea for this?



