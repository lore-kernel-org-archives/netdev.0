From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Tue, 20 May 2014 10:50:58 -0400
Message-ID: <537B6BD2.3060204@gmail.com>
References: <20140520105952.73f6adab@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vlad Yasevich <vyasevic@redhat.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140520105952.73f6adab@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/19/2014 08:59 PM, Stephen Rothwell wrote:
> Hi all,
> 
> After merging the net tree, today's linux-next build (powerpc
> ppc64_defconfig) failed like this:
> 
> 
> In file included from arch/powerpc/net/bpf_jit_comp.c:16:0:
> include/linux/if_vlan.h: In function 'vlan_get_encap_level':
> include/linux/if_vlan.h:491:2: error: implicit declaration of function 'vlan_dev_priv' [-Werror=implicit-function-declaration]
>   return vlan_dev_priv(dev)->nest_level;
>   ^
> include/linux/if_vlan.h:491:27: error: invalid type argument of '->' (have 'int')
>   return vlan_dev_priv(dev)->nest_level;
>                            ^
> 
> Caused by commit 44a4085538c8 ("bonding: Fix stacked device detection
> in arp monitoring").
> 
> vlan_dev_priv() is protected by:
> 
> #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
> 
> but the newly added call in vlan_get_encap_level() is not.
> 
> I have used the net tree from next-20140519 for today.
> 

Right.  Apologies.  I missed the above fact.  Fix forthcoming.

-vlad
