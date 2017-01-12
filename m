From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH 5/6] treewide: use kv[mz]alloc* rather than opencoded
 variants
Date: Thu, 12 Jan 2017 17:05:58 +0100
Message-ID: <1a293278-63ab-c54d-0872-0bed42e9710e@de.ibm.com>
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-6-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Vlastimil Babka <vbabka@suse.cz>,
        David Rientjes <rientjes@google.com>,
        Mel Gorman <mgorman@suse.de>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org,
        LKML <linux-kernel@vger.kernel.org>,
        Michal Hocko <mhocko@suse.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Anton Vorontsov <anton@enomsg.org>,
        Colin Cross <ccross@android.com>,
        Kees Cook <keescook@chromium.org>,
        Tony Luck <tony.luck@intel.com>,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Ben Skeggs <bskeggs@redhat.com>,
        Kent Overstreet <kent.overstreet@gmail.com>,
        Santosh Raspatur <santosh@chelsio.com>,
        Hariprasad S <hariprasad@chelsio.com>,
        Tariq Toukan
To: Michal Hocko <mhocko@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170112153717.28943-6-mhocko@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/12/2017 04:37 PM, Michal Hocko wrote:
> diff --git a/arch/s390/kvm/kvm-s390.c b/arch/s390/kvm/kvm-s390.c
> index 4f74511015b8..e6bbb33d2956 100644
> --- a/arch/s390/kvm/kvm-s390.c
> +++ b/arch/s390/kvm/kvm-s390.c
> @@ -1126,10 +1126,7 @@ static long kvm_s390_get_skeys(struct kvm *kvm, struct kvm_s390_skeys *args)
>  	if (args->count < 1 || args->count > KVM_S390_SKEYS_MAX)
>  		return -EINVAL;
> 
> -	keys = kmalloc_array(args->count, sizeof(uint8_t),
> -			     GFP_KERNEL | __GFP_NOWARN);
> -	if (!keys)
> -		keys = vmalloc(sizeof(uint8_t) * args->count);
> +	keys = kvmalloc(args->count * sizeof(uint8_t), GFP_KERNEL);
>  	if (!keys)
>  		return -ENOMEM;
> 
> @@ -1171,10 +1168,7 @@ static long kvm_s390_set_skeys(struct kvm *kvm, struct kvm_s390_skeys *args)
>  	if (args->count < 1 || args->count > KVM_S390_SKEYS_MAX)
>  		return -EINVAL;
> 
> -	keys = kmalloc_array(args->count, sizeof(uint8_t),
> -			     GFP_KERNEL | __GFP_NOWARN);
> -	if (!keys)
> -		keys = vmalloc(sizeof(uint8_t) * args->count);
> +	keys = kvmalloc(sizeof(uint8_t) * args->count, GFP_KERNEL);
>  	if (!keys)
>  		return -ENOMEM;

KVM/s390 parts

Acked-by: Christian Borntraeger <borntraeger@de.ibm.com>
