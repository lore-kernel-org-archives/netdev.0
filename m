From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][IPV6] keeping dst refcnt correctly with using xfrm
Date: Thu, 05 Jun 2003 22:55:47 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030605.225547.28789693.davem@redhat.com>
References: <20030606144925.29ad2a9f.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, usagi@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kazunori@miyazawa.org
In-Reply-To: <20030606144925.29ad2a9f.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Kazunori Miyazawa <kazunori@miyazawa.org>
   Date: Fri, 6 Jun 2003 14:49:25 +0900

   In dst_pop refernce cound of dsts except for last are incremented in
   dst_clone and decremented in next call dst_pop but last dst refernce
   count will be never decremented.
   All dst are held by xfrm_policy and there is no need to touch the
   refernce count here.
   
Ok, so the idea is to hold onto top-level parent DST entry the entire
time, and this prevents the DST and all it's children from being
destroyed.  Is this correct?

Let me study this a little bit, I want to make sure it is correct.
