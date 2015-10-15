From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] Fix sleeping memory allocation in atomic context
Date: Thu, 15 Oct 2015 12:13:36 +0200
Message-ID: <561F7C50.6080401@cumulusnetworks.com>
References: <1444899472-8191-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	operations@siteground.com
To: Nikolay Borisov <kernel@kyup.com>, kadlec@blackhole.kfki.hu
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1444899472-8191-1-git-send-email-kernel@kyup.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/15/2015 10:57 AM, Nikolay Borisov wrote:
> Ipset 6.26 produces the following splat:
> 
[snip]
> 
> The call chain leading to this as follow:
> call_add -> list_set_uadt -> list_set_uadd -> kzalloc(, GFP_KERNEL).
> And since GFP_KERNEL allows initiating direct reclaim thus
> potentially sleeping in the allocation path, this leads to the
> aforementioned splat.
> 
> To fix it change that particular allocation type to GFP_ATOMIC, to
> correctly reflect that it is happening in an atomic context.
> 
> Signed-off-by: Nikolay Borisov <kernel@kyup.com>
> ---
> 
> Even though this patch has been generated against the stand-alone
> ipset sources I just checked the 4.3-rc4 sources and the problem
> exists there as well.
> 
>  kernel/net/netfilter/ipset/ip_set_list_set.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/kernel/net/netfilter/ipset/ip_set_list_set.c b/kernel/net/netfilter/ipset/ip_set_list_set.c
> index b11ba96..0f9195f 100644

Hi,
You should fix your subject line to include the subsystem [1], something like
netfilter: ipset: fix...
The path to the file being patched is incorrect, patches should be generated in
the root kernel source dir [2].
Also it'd be nice to add a Fixes tag [3] to show which commit introduced the bug,
in this case it looks like it's:
Fixes: 00590fdd5be0 ("netfilter: ipset: Introduce RCU locking in list type")

Cheers,
 Nik

[1] Documentation/SubmittingPatches chapter 14
[2] Documentation/SubmittingPatches chapter 1
[3] Documentation/SubmittingPatches chapters 2 and 13

