From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] rhashtable-test: retry insert operations in threads
Date: Sat, 29 Aug 2015 00:43:03 +0200
Message-ID: <20150828224303.GD32001@pox.localdomain>
References: <1440757685-14241-1-git-send-email-phil@nwl.cc>
 <1440757685-14241-2-git-send-email-phil@nwl.cc>
 <20150828110929.GI32206@pox.localdomain>
 <20150828111320.GL20760@orbit.nwl.cc>
 <20150828133437.GM20760@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150828133437.GM20760@orbit.nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/28/15 at 03:34pm, Phil Sutter wrote:
> Quite ugly, IMHO: rhashtable_insert_fast() may return -ENOMEM as
> non-permanent error, if allocation in GFP_ATOMIC failed. In this case,
> allocation in GFP_KERNEL is retried by rht_deferred_worker(). Sadly,
> there is no way to determine if that has already been tried and failed.
> 
> The thread test triggers GFP_ATOMIC allocation failure quite easily, so
> I can't really just ignore this issue. :)

Return EBUSY or ENOBUFS in the non-permanent case? It is definitely
helpful if the API allows to differ between permanent and
non-permanent errors.
