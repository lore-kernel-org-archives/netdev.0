From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 1/4] inotify: Add infrastructure to account inotify
 limits per-namespace
Date: Mon, 6 Jun 2016 11:05:57 +0300
Message-ID: <20160606080557.GG2211@uranus.lan>
References: <1464767580-22732-1-git-send-email-kernel@kyup.com>
 <1464767580-22732-2-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john@johnmccutchan.com, eparis@redhat.com, ebiederm@xmission.com,
	jack@suse.cz, linux-kernel@vger.kernel.org, avagin@openvz.org,
	netdev@vger.kernel.org, operations@siteground.com
To: Nikolay Borisov <kernel@kyup.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1464767580-22732-2-git-send-email-kernel@kyup.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 01, 2016 at 10:52:57AM +0300, Nikolay Borisov wrote:
> This patch adds the necessary members to user_struct. The idea behind
> the solution is really simple - user the userns pointers as keys into
> a hash table which holds the inotify instances/watches counts. This
> allows to account the limits per userns rather than per real user,
> which makes certain scenarios such as a single mapped user in a
> container deplete the inotify resources for all other users, which
> map to the exact same real user.
> 
> Signed-off-by: Nikolay Borisov <kernel@kyup.com>
...
> +static inline unsigned long inotify_dec_return_dev(struct user_struct *user,
> +						   void *key)
> +{
> +	struct inotify_state *state;
> +	unsigned long ret;
> +
> +	spin_lock(&user->inotify_lock);
> +	state = __find_inotify_state(user, key);
> +	ret = --state->inotify_devs;
> +	spin_unlock(&user->inotify_lock);
> +
> +	return ret;
> +}

Hi Nikolay! Could you please explain why this new function is not used anywhere
in other patches or I miss something obvious?
