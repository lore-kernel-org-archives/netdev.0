From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] netfilter: xt_hashlimit: fix build error caused by
 64bit division
Date: Fri, 8 Sep 2017 14:56:35 +0200
Message-ID: <20170908125635.GA27811@salvia>
References: <1504849138-17427-1-git-send-email-vpai@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, torvalds@linux-foundation.org,
        davem@davemloft.net, kadlec@blackhole.kfki.hu, johunt@akamai.com,
        fw@strlen.de, netdev@vger.kernel.org, pai.vishwain@gmail.com,
        mingo@kernel.org, ilubashe@akamai.com, bp@alien8.de,
        luto@kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org,
        brgerst@gmail.com, andrew.cooper3@citrix.com, jgross@suse.com,
        boris.ostrovsky@oracle.com, keescook@chromium.org,
        akpm@linux-foundation.org, arnd@arndb.de
To: Vishwanath Pai <vpai@akamai.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1504849138-17427-1-git-send-email-vpai@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 08, 2017 at 01:38:58AM -0400, Vishwanath Pai wrote:
> 64bit division causes build/link errors on 32bit architectures. It
> prints out error messages like:
> 
> ERROR: "__aeabi_uldivmod" [net/netfilter/xt_hashlimit.ko] undefined!
> 
> The value of avg passed through by userspace in BYTE mode cannot exceed
> U32_MAX. Which means 64bit division in user2rate_bytes is unnecessary.
> To fix this I have changed the type of param 'user' to u32.
> 
> Since anything greater than U32_MAX is an invalid input we error out in
> hashlimit_mt_check_common() when this is the case.
> 
> Changes in v2:
> 	Making return type as u32 would cause an overflow for small
> 	values of 'user' (for example 2, 3 etc). To avoid this I bumped up
> 	'r' to u64 again as well as the return type. This is OK since the
> 	variable that stores the result is u64. We still avoid 64bit
> 	division here since 'user' is u32.

Applied, thanks.
