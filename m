From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH BUGFIX -v2 -rc4] Smack: Respect 'unlabeled' netlabel
 mode
Date: Fri, 30 May 2008 16:25:00 -0700
Message-ID: <20080530162500.1411f14d.akpm@linux-foundation.org>
References: <20080530233603.GA2994@ubuntu>
	<20080530235751.GA6888@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: casey@schaufler-ca.com, paul.moore@hp.com,
	linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Ahmed S. Darwish" <darwish.07@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080530235751.GA6888@ubuntu>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 31 May 2008 02:57:51 +0300
"Ahmed S. Darwish" <darwish.07@gmail.com> wrote:

> +		mutex_lock(&smack_ambient_lock);
> +		nlsp->domain = kstrdup(smack_net_ambient, GFP_ATOMIC);
> +		mutex_unlock(&smack_ambient_lock);

no no no no no.  And no.

GFP_ATOMIC is *unreliable*.  Using it in a "security" feature is a bug
- if it fails, the feature isn't secure any more.

Failing to check the kmalloc() return value might be a bug.

If we _need_ GFP_ATOMIC here then taking a mutex in a cannot-sleep
context is a bug.

The patch adds a kmalloc but doesn't add a kfree.  Is it leaky?

Finally, why is there a need to take a lock around a single store
instruction?
