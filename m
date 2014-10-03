From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [RFC PATCH linux 2/2] fs/proc: use a hash table for the directory entries
Date: Fri, 3 Oct 2014 13:55:51 +0300
Message-ID: <CACVxJT98EJvw1E+o6mpu8ugMz3Ztqz7pJOwZeZW9A41P0AhB_g@mail.gmail.com>
References: <20131003.150947.2179820478039260398.davem@davemloft.net>
	<1412263501-6572-1-git-send-email-nicolas.dichtel@6wind.com>
	<1412263501-6572-3-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	rui.xiang@huawei.com, Al Viro <viro@zeniv.linux.org.uk>,
	Oleg Nesterov <oleg@redhat.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	kirill.shutemov@linux.intel.com,
	Grant Likely <grant.likely@secretlab.ca>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Thierry Herbelot <thierry.herbelot@6wind.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412263501-6572-3-git-send-email-nicolas.dichtel@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 2, 2014 at 6:25 PM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> --- a/fs/proc/generic.c
> +++ b/fs/proc/generic.c
> @@ -81,10 +81,13 @@ static int __xlate_proc_name(const char *name, struct proc_dir_entry **ret,

> +       if (!S_ISDIR(de->mode))
> +               return -EINVAL;

There are way too many S_ISDIR checks.
In lookup and readdir, it is guaranteed that PDE is directory.

I'd say all of them aren't needed because non-directories have
->subdir = NULL and
directories have ->subdir != NULL which transforms into hashtable or
rbtree or whatever,
so you only need to guarantee only directories appear where they are
expected and
fearlessly use your new data structure traversing directories.

    Alexey
