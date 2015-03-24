From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH 01/11] sysctl: make some functions unstatic to
 access by arch/lib
Date: Tue, 24 Mar 2015 09:13:39 -0700
Message-ID: <1427213619.5642.34.camel@perches.com>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>
	 <1427202642-1716-2-git-send-email-tazaki@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-arch@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Jonathan
 Corbet <corbet@lwn.net>, Jhristoph Lameter <cl@linux.com>, Jekka Enberg
 <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim
 <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
 netdev@vger.kernel.org,  linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>,
 Richard Weinberger <richard@nod.at>, Rusty Russell <rusty@rustcorp.com.au>,
 Mathieu Lacage <mathieu.lacage@gmail.com>
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1427202642-1716-2-git-send-email-tazaki@sfc.wide.ad.jp>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-03-24 at 22:10 +0900, Hajime Tazaki wrote:
> libos (arch/lib) emulates a sysctl-like interface by a function call of
> userspace by enumerating sysctl tree from sysctl_table_root. It requires
> to be publicly accessible to this symbol and related functions.
[]
> diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
[]
> @@ -77,7 +77,7 @@ static int namecmp(const char *name1, int len1, const char *name2, int len2)
>  }
>  
>  /* Called under sysctl_lock */
> -static struct ctl_table *find_entry(struct ctl_table_header **phead,
> +struct ctl_table *find_entry(struct ctl_table_header **phead,

find_entry and all of the <foo>_entry functions below it
are overly generic names.  Maybe prefix with ctl_table_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
