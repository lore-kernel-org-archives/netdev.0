From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH linux v3 1/1] fs/proc: use a rb tree for the directory
 entries
Date: Wed, 15 Oct 2014 14:37:45 -0700
Message-ID: <20141015143745.6b00efce5bf8a302d2befca3@linux-foundation.org>
References: <20141006.181448.1696747135961247651.davem@davemloft.net>
	<1412672559-5256-1-git-send-email-nicolas.dichtel@6wind.com>
	<1412672559-5256-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, ebiederm@xmission.com, adobriyan@gmail.com,
	rui.xiang@huawei.com, viro@zeniv.linux.org.uk, oleg@redhat.com,
	gorcunov@openvz.org, kirill.shutemov@linux.intel.com,
	grant.likely@secretlab.ca, tytso@mit.edu
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412672559-5256-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue,  7 Oct 2014 11:02:39 +0200 Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> The current implementation for the directories in /proc is using a single
> linked list. This is slow when handling directories with large numbers of
> entries (eg netdevice-related entries when lots of tunnels are opened).
> 
> This patch replaces this linked list by a red-black tree.
> 
> ...
>
> --- a/fs/proc/root.c
> +++ b/fs/proc/root.c
> @@ -166,6 +166,7 @@ void __init proc_root_init(void)
>  {
>  	int err;
>  
> +	proc_root.subdir = RB_ROOT;
>  	proc_init_inodecache();
>  	err = register_filesystem(&proc_fs_type);
>  	if (err)

This can be done at compile time can't it?

--- a/fs/proc/root.c~fs-proc-use-a-rb-tree-for-the-directory-entries-fix
+++ a/fs/proc/root.c
@@ -166,7 +166,6 @@ void __init proc_root_init(void)
 {
 	int err;
 
-	proc_root.subdir = RB_ROOT;
 	proc_init_inodecache();
 	err = register_filesystem(&proc_fs_type);
 	if (err)
@@ -252,6 +251,7 @@ struct proc_dir_entry proc_root = {
 	.proc_iops	= &proc_root_inode_operations, 
 	.proc_fops	= &proc_root_operations,
 	.parent		= &proc_root,
+	.subdir		= RB_ROOT,
 	.name		= "/proc",
 };
 
_
