From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] af_unix: Fix splice-bind deadlock
Date: Sun, 03 Jan 2016 18:04:58 +0000
Message-ID: <87vb7ak08l.fsf@doppelsaurus.mobileactivedefense.com>
References: <87y4cftztp.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <dvyukov@google.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <viro@ZenIV.linux.org.uk>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87y4cftztp.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Sun, 27 Dec 2015 20:13:22 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:

[...]

> +	dentry = NULL;
> +	if (sun_path[0]) {
> +		/* Get the parent directory, calculate the hash for last
> +		 * component.
> +		 */
> +		dentry = kern_path_create(AT_FDCWD, sun_path, &path, 0);
> +
> +		err = PTR_ERR(dentry);
> +		if (IS_ERR(dentry))
> +			goto out;
> +	}
> +

This is wrong because kern_path_create can return with -EEXIST which
needs to be translated to -EADDRINUSE for this case. I'll fix that.
