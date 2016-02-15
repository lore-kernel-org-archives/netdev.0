From: Nikolay Borisov <kernel@kyup.com>
Subject: Re: linux-next: build warning after merge of the net-next tree
Date: Mon, 15 Feb 2016 10:01:13 +0200
Message-ID: <56C185C9.4020407@kyup.com>
References: <20160215130941.4ce2ae28@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160215130941.4ce2ae28@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 02/15/2016 04:09 AM, Stephen Rothwell wrote:
> Hi all,
> 
> After merging the net-next tree, today's linux-next build (arm
> multi_v7_defconfig) produced this warning:
> 
> net/ipv4/igmp.c: In function 'igmp_group_added':
> net/ipv4/igmp.c:1227:14: warning: unused variable 'net' [-Wunused-variable]
>   struct net *net = dev_net(in_dev->dev);
>               ^
> net/ipv4/igmp.c: In function 'ip_mc_inc_group':
> net/ipv4/igmp.c:1319:14: warning: unused variable 'net' [-Wunused-variable]
>   struct net *net = dev_net(in_dev->dev);
>               ^
> net/ipv4/igmp.c: In function 'ip_mc_init_dev':
> net/ipv4/igmp.c:1646:14: warning: unused variable 'net' [-Wunused-variable]
>   struct net *net = dev_net(in_dev->dev);
>               ^
> net/ipv4/igmp.c: In function 'ip_mc_up':
> net/ipv4/igmp.c:1665:14: warning: unused variable 'net' [-Wunused-variable]
>   struct net *net = dev_net(in_dev->dev);
>               ^
> 
> Introduced by commits
> 
>   87a8a2ae65b7 ("igmp: Namespaceify igmp_llm_reports sysctl knob")
>   165094afcee7 ("igmp: Namespacify igmp_qrv sysctl knob")
> 
> CONFIG_IP_MULTICAST is not set for this build.

Right, I have forgotten to add the ifdef guards for the respective
variables, will squeeze a patch in the next series on namespaceifying
various sysctls.

Thanks for testing!
