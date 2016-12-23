From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCHv2 net] netfilter: check duplicate config when
 initializing in ipt_CLUSTERIP
Date: Fri, 23 Dec 2016 15:18:37 +0100
Message-ID: <20161223141837.GA21441@salvia>
References: <b96e06fc4b0bc50a3c39dffebbcd43685d2e2a0b.1482232474.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>,
        netfilter-devel@vger.kernel.org, davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <b96e06fc4b0bc50a3c39dffebbcd43685d2e2a0b.1482232474.git.lucien.xin@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 20, 2016 at 07:14:34PM +0800, Xin Long wrote:
> Now when adding an ipt_CLUSTERIP rule, it only checks duplicate config in
> clusterip_config_find_get(). But after that, there may be still another
> thread to insert a config with the same ip, then it leaves proc_create_data
> to do duplicate check.
> 
> It's more reasonable to check duplicate config by ipt_CLUSTERIP itself,
> instead of checking it by proc fs duplicate file check. Before, when proc
> fs allowed duplicate name files in a directory, It could even crash kernel
> because of use-after-free.
> 
> This patch is to check duplicate config under the protection of clusterip
> net lock when initializing a new config and correct the return err.
> 
> Note that it also moves proc file node creation after adding new config, as
> proc_create_data may sleep, it couldn't be called under the clusterip_net
> lock. clusterip_config_find_get returns NULL if c->pde is null to make sure
> it can't be used until the proc file node creation is done.

Applied, thanks.
