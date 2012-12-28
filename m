From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 01/19] netfilter: move nf_conntrack initialize out of
 pernet operations
Date: Fri, 28 Dec 2012 15:16:07 +0800
Message-ID: <50DD4737.2070306@cn.fujitsu.com>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com> <CAFFEFTXT_fkF2pPSxDEEgic80NVWLqBWtFuvs6W9uDUW2aCnqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, pablo@netfilter.org,
	ebiederm@xmission.com
To: canqun zhang <canqunzhang@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAFFEFTXT_fkF2pPSxDEEgic80NVWLqBWtFuvs6W9uDUW2aCnqw@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/28/12 11:52, canqun zhang wrote:
> Hi all
> As discussed above,if the host machine create several linux
> containers, there will be several  net namespaces.Resources with "nf
> conntrack" are registered or unregistered on the first net
> namespace(init_net),But init_net is not unregistered lastly,so
> cleanuping other net namespaces  will triger painic.
> If net namespaces are created  with the order of 1,2,...n,they should
> be cleaned with the order of n,...2,1,so in this case init_net will be
> unregistered lastly.
> I fixed it up (see below). I have taken a lot of test!
> 

I thinks this BUG is a netfilter BUG,not a netns BUG.
Other subsystems implemented netns support don't use init_net to
do some special works((un)register/(un)set).

In fact,we can't use init_net to do this job well.such as function
nf_conntrack_clean,we shoud set ip_ct_attach to NULL before any
netns doing cleanup jobs, and set nf_ct_destroy to NULL after all of
netns finish these cleanup jobs.

So I think finally we still need this patchset,And this is a regular
way to fix this problem.

Can you help me to test if the panic bug is fixed by this patchset?
and then give me your tested-by?

thank you very much!
