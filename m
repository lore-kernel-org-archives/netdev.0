From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Refine IPv6 Address Validation Timer
Date: Fri, 27 Sep 2002 02:25:15 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020927.022515.78074730.davem@redhat.com>
References: <20020927.181256.112824147.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, usagi@linux-ipv6.org,
   kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20020927.181256.112824147.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Fri, 27 Sep 2002 18:12:56 +0900 (JST)

This patch has problems.
    
   @@ -1626,24 +1635,32 @@
    		for (ifp=inet6_addr_lst[i]; ifp; ifp=ifp->lst_next) {
    			unsigned long age;
    
   -			if (ifp->flags & IFA_F_PERMANENT)
   +			spin_lock(&ifp->lock);
   +			if (ifp->flags & IFA_F_PERMANENT) {
   +				spin_unlock(&ifp->lock);
    				continue;
   +			}

This is completely unnecessary.  Nobody modifies the
IFA_F_PERMANENT flag after the addr entry has been added
to the hash table and this runs under the addrconf hash
lock already.

Alexey will have to comment on the rest.
