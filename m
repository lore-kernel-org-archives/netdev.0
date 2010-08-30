From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: block network access for certain users/groups
Date: Mon, 30 Aug 2010 20:55:43 +0900
Message-ID: <201008302055.GEG52699.MJHtQLFOFOSFVO@I-love.SAKURA.ne.jp>
References: <AANLkTin8w74SAe67ZPqPE0Q=0fPpZOHnTCnjAT+AduCY@mail.gmail.com>
	<AANLkTikru-pmMAnS-dqjYT7xJC_X21rVNBpjg_2LDmWB@mail.gmail.com>
	<201008252058.DDE12933.FOLOHQSJFFOMtV@I-love.SAKURA.ne.jp>
	<201008262128.DCG04175.JFQFLFVOMHOtSO@I-love.SAKURA.ne.jp>
	<AANLkTi=HpQNM_FeHDdejnh-q-RhLMFVK3-O5JgWKejA0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: estellnb@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=HpQNM_FeHDdejnh-q-RhLMFVK3-O5JgWKejA0@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Elmar Stellnberger wrote:
> However if I compile the kernel module and try to load it that results
> in a kernel hang that I can only escape by Alt-PrnScr-S-U-B, no matter
> whether the module is loaded on boot time or in rl5. I have checked
> all required kernel options and built it like the following (using
> openSUSE 11.3):

This module is for 2.6.36 but openSUSE 11.3 uses 2.6.34 . Did you change
below spin_lock() to write_lock() and spin_unlock() to write_unlock()?

> > 	{
> > 		struct fs_struct *fs = current->fs;
> > 		struct vfsmount *mnt = current->nsproxy->pid_ns->proc_mnt;
> > 		struct path old_path;
> > 		struct path new_path = { mnt, mnt->mnt_root };
> > 		spin_lock(&fs->lock); /* was write_lock() till 2.6.35. */
> > 		old_path = fs->pwd;
> > 		fs->pwd = new_path;
> > 		spin_unlock(&fs->lock);
> > 		file = filp_open("kallsyms", O_RDONLY, 0);
> > 		spin_lock(&fs->lock);
> > 		fs->pwd = old_path;
> > 		spin_unlock(&fs->lock);
> > 	}
