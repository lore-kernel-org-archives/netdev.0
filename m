From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ppp: ppp_generic.c initialize flen before it get used
Date: Sat, 12 Sep 2009 23:17:26 -0700 (PDT)
Message-ID: <20090912.231726.165876349.davem@davemloft.net>
References: <1252773691.3687.5.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gabriele.paoloni@intel.com, paulus@samba.org,
	linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: jaswinder@kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1252773691.3687.5.camel@ht.satnam>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Already dealt with in net-next-2.6, please act against the
active networking development trees when fixing warnings and
doing cleanups.

Thank you.

commit 886f9fe68310168358f55028a03553ae154dfeb6
Author: David S. Miller <davem@davemloft.net>
Date:   Wed Aug 19 13:55:55 2009 -0700

    ppp_generic: Help GCC see that 'flen' is always initialized.
    
    It's too stupid to see that we always set flen to something
    before we use it in ppp_mp_explode():
    
    drivers/net/ppp_generic.c: In function 'ppp_push':
    drivers/net/ppp_generic.c:1314: warning: 'flen' may be used uninitialized in this function
    drivers/net/ppp_generic.c:1314: note: 'flen' was declared here
    
    This started warning after commit a53a8b56827cc429c6d9f861ad558beeb5f6103f
    ("ppp: fix lost fragments in ppp_mp_explode() (resubmit)")
    
    So just put an explicit unconditional initialization there to
    hush it up.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

