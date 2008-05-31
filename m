From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH BUGFIX -v2 -rc4] Smack: Respect 'unlabeled' netlabel
	mode
Date: Sat, 31 May 2008 04:12:42 +0300
Message-ID: <20080531011242.GA7061@ubuntu>
References: <20080530233603.GA2994@ubuntu> <20080530235751.GA6888@ubuntu> <20080530162500.1411f14d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: casey@schaufler-ca.com, paul.moore@hp.com,
	linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080530162500.1411f14d.akpm@linux-foundation.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 30, 2008 at 04:25:00PM -0700, Andrew Morton wrote:
> On Sat, 31 May 2008 02:57:51 +0300
> "Ahmed S. Darwish" <darwish.07@gmail.com> wrote:
> 
> > +		mutex_lock(&smack_ambient_lock);
> > +		nlsp->domain = kstrdup(smack_net_ambient, GFP_ATOMIC);
> > +		mutex_unlock(&smack_ambient_lock);
> 
> no no no no no.  And no.
> 
> GFP_ATOMIC is *unreliable*.  Using it in a "security" feature is a bug
> - if it fails, the feature isn't secure any more.
> 
> Failing to check the kmalloc() return value might be a bug.
> 
> If we _need_ GFP_ATOMIC here then taking a mutex in a cannot-sleep
> context is a bug.
> 
> The patch adds a kmalloc but doesn't add a kfree.  Is it leaky?
> 
> Finally, why is there a need to take a lock around a single store
> instruction?

Possibly the worst three lines written ever. GFP_ATOMIC line
was cut-and-paste forgetting to change it to GFP_KERNEL and the lock
is already useless. 

-- 

"Better to light a candle, than curse the darkness"

Ahmed S. Darwish
Homepage: http://darwish.07.googlepages.com
Blog: http://darwish-07.blogspot.com

