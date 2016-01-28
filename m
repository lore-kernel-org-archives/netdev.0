From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] lib: fix callers of strtobool to use char array
Date: Wed, 27 Jan 2016 16:58:28 -0800
Message-ID: <1453942708.10099.41.camel@perches.com>
References: <20160128004542.GA15247@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Steve French <sfrench@samba.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-cifs@vger.kernel.org, samba-technical@lists.samba.org
To: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160128004542.GA15247@www.outflux.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-01-27 at 16:45 -0800, Kees Cook wrote:
> Some callers of strtobool were passing a pointer to unterminated stri=
ngs.
> This fixes the issue and consolidates some logic in cifs.

This may be incomplete as it duplicates the behavior for
the old number of characters, but this is not a solution
for the entry of a bool that is "on" or "off".

> diff --git a/fs/cifs/cifs_debug.c b/fs/cifs/cifs_debug.c
[]
> @@ -290,7 +305,8 @@ static ssize_t cifs_stats_proc_write(struct file =
*file,
> =A0			}
> =A0		}
> =A0		spin_unlock(&cifs_tcp_ses_lock);
> -	}
> +	} else
> +		return rc;

Likely better to reverse the test and unindent the
preceding block.

Otherwise, please make sure to use the general brace
form of when one branch needs braces, the other branch
should have them too.
