From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] qlge: Replace create_singlethread_workqueue with
 alloc_ordered_workqueue
Date: Thu, 14 Apr 2016 11:47:00 -0400
Message-ID: <20160414154700.GE12583@htj.duckdns.org>
References: <20160409115744.GA30104@amitoj-Inspiron-3542>
 <20160413174422.GB3676@htj.duckdns.org>
 <BLUPR11MB011498CD02CC919F023545E793970@BLUPR11MB0114.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amitoj Kaur Chawla <amitoj1606@gmail.com>,
	Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>,
	Harish Patil <harish.patil@qlogic.com>,
	Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@qlogic.com>
To: Manish Chopra <manish.chopra@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BLUPR11MB011498CD02CC919F023545E793970@BLUPR11MB0114.namprd11.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Manish.

On Thu, Apr 14, 2016 at 07:25:15AM +0000, Manish Chopra wrote:
> Just want to confirm that __WQ_LEGACY flag is not necessary here as this is removed
> with this change ? 

Yeah, that should be fine.  That only affects locking dependency
tracking which can fire spuriously due to workqueues created with the
old interface having WQ_MEM_RECLAIM unconditionally.  In this case, we
actually want WQ_MEM_RECLAIM and thus we want the dependency tracking
too.

Thanks.

-- 
tejun
