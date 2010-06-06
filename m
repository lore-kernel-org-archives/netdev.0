From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH v7 01/19] Add a new structure for skb buffer from
 external.
Date: Sun, 6 Jun 2010 16:13:48 -0700
Message-ID: <20100606161348.427822fb@nehalam>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Still not sure this is a good idea for a couple of reasons:

1. We already have lots of special cases with skb's (frags and fraglist),
   and skb's travel through a lot of different parts of the kernel.  So any
   new change like this creates lots of exposed points for new bugs. Look
   at cases like MD5 TCP and netfilter, and forwarding these SKB's to ipsec
   and ppp and ...

2. SKB's can have infinite lifetime in the kernel. If these buffers come from
   a fixed size pool in an external device, they can easily all get tied up
   if you have a slow listener. What happens then?
