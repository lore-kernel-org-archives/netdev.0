From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 4/6] bpf: hash: convert per-hashtable lock into
 per-bucket bit spinlock
Date: Thu, 17 Dec 2015 22:20:44 -0800
Message-ID: <20151218062043.GB59584@ast-mbp.thefacebook.com>
References: <1450178464-27721-1-git-send-email-tom.leiming@gmail.com>
 <1450178464-27721-5-git-send-email-tom.leiming@gmail.com>
 <20151215225118.GA67370@ast-mbp.thefacebook.com>
 <CACVXFVMaRPSHCEi9BpA1R9FnQFhUODc6UVonE_SjiytmL2WAXQ@mail.gmail.com>
 <CAHbLzkpW_seTrs+WgFqsriH5uhG4LMY_jiYC0iRQ-LAdJFiUjw@mail.gmail.com>
 <CACVXFVOeh0D+Nf8AVw68-e-aSYtVVLiRoUoDCi89zYXXiUm4gA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yang Shi <shy828301@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACVXFVOeh0D+Nf8AVw68-e-aSYtVVLiRoUoDCi89zYXXiUm4gA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 16, 2015 at 02:58:08PM +0800, Ming Lei wrote:
> On Wed, Dec 16, 2015 at 1:01 PM, Yang Shi <shy828301@gmail.com> wrote:
> 
> >
> > I recalled Steven confirmed raw_spin_lock has the lockdep benefit too in the
> > patch review for changing to raw lock.
> >
> > Please check this thread out
> >  http://lists.openwall.net/netdev/2015/10/31/7
> 
> OK, looks I was wrong about the lockdep benifit, :-(
> 
> But for this lock, I think lockdep isn't such important, because it is the
> intermost lock, and it can be used just for protecting the bucket list
> and nothing else need to be covered.

I still think that overhead of normal spinlock per bucket is acceptable.
Makes the whole thing much easier to read.
