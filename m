From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH crypto] crypto: algboss: fix NULL pointer dereference
 in cryptomgr_probe
Date: Mon, 24 Jun 2013 16:33:06 +0200
Message-ID: <51C858A2.40801@redhat.com>
References: <1371715221-27192-1-git-send-email-dborkman@redhat.com> <20130624135943.GA11776@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20130624135943.GA11776@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/24/2013 03:59 PM, Herbert Xu wrote:
...
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Mon Jun 24 21:57:42 2013 +0800
>
>      crypto: algboss - Hold ref count on larval
>
...
>
>      The use of wait_for_completion_interruptible is intentional so that
>      we don't lock up the thread if a bug causes us to never wake up.
>
>      This bug is caused by the helper thread using the larval without
>      holding a reference count on it.  If the helper thread completes
>      after the original thread requesting for help has gone away and
>      destroyed the larval, then we get the crash above.
>
>      So the fix is to hold a reference count on the larval.
>
>      Cc: <stable@vger.kernel.org> # 3.6+
>      Reported-by: Daniel Borkmann <dborkman@redhat.com>
>      Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Tested-by: Daniel Borkmann <dborkman@redhat.com>

This fixes the panic for me with the reproducer I sent off-list.

Thanks Herbert !
