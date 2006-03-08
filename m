From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [patch 1/4] net: percpufy frequently used vars -- add percpu_counter_mod_bh
Date: Wed, 8 Mar 2006 15:36:42 -0500
Message-ID: <20060308203642.GZ5410@kvack.org>
References: <20060308015808.GA9062@localhost.localdomain> <20060308015934.GB9062@localhost.localdomain> <20060307181301.4dd6aa96.akpm@osdl.org> <20060308202656.GA4493@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org, shai@scalex86.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932454AbWCHUmE@vger.kernel.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Content-Disposition: inline
In-Reply-To: <20060308202656.GA4493@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 08, 2006 at 12:26:56PM -0800, Ravikiran G Thirumalai wrote:
> +static inline void percpu_counter_mod_bh(struct percpu_counter *fbc, long amount)
> +{
> +	local_bh_disable();
> +	fbc->count += amount;
> +	local_bh_enable();
> +}

Please use local_t instead, then you don't have to do the local_bh_disable() 
and enable() and the whole thing collapses down into 1 instruction on x86.

		-ben
