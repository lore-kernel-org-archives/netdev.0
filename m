From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: How can OOM killer detect process consuming much kernel memory?
Date: Fri,  3 Sep 2010 15:32:05 +0900 (JST)
Message-ID: <20100903122536.3FC8.A69D9226@jp.fujitsu.com>
References: <201008302227.DJH30258.OQFMFtFJOOVSHL@I-love.SAKURA.ne.jp> <201009020633.DHJ01355.OQFMLtHSVOOJFF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, spender@grsecurity.net,
	eric.dumazet@gmail.com
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201009020633.DHJ01355.OQFMLtHSVOOJFF@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Is it possible to make OOM killer to kill processes consuming kernel memory
> rather than userspace memory?
> 
> I'm happy if OOM killer can select victim process based on both kernel memory
> usage and userspace memory usage. For example, opening a file requires kernel
> memory allocation (e.g. /sys/kernel/security/tomoyo/self_domain allocates 8KB
> of kernel memory). Therefore, I refuse allowing everybody to open that file
> even if the content is public (because an attacker would open
> /sys/kernel/security/tomoyo/self_domain as many as possible using
> fork() and open() in order to exhaust kernel memory).

Unfortunatelly, It's impossible. We have zero information which kernel
memory should be bound caller task. Almost all kernel memory are task
unrelated, so we can't bind them with caller task blindly.

Thanks.
