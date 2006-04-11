From: John Heffner <jheffner@psc.edu>
Subject: Re: 2.6.17 regression: Very slow net transfer from some hosts
Date: Tue, 11 Apr 2006 15:23:56 -0400
Message-ID: <443C024C.2070107@psc.edu>
References: <443C03E6.7080202@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751081AbWDKTYG@vger.kernel.org>
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <443C03E6.7080202@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Drake wrote:
> Hi,
> 
> Since sometime after 2.6.16, some websites have been very slow to load. 
>  Examples include:
> 
> http://zd1211.ath.cx
> http://developer.osdl.org/shemminger/blog/
> http://www.reactivated.net/weblog
> 
> On a good kernel, "wget http://zd1211.ath.cx" says:
> 20:23:38 (90.44 KB/s) - `index.html' saved [20895/20895]
> 
> On a bad kernel:
> 20:14:18 (327.01 B/s) - `index.html' saved [20895/20895]
> 
> I reproduced this on two different internet connections (same ISP 
> though). However I cannot reproduce it on my other system.
> 
> git-bisect tracked it down to:
> 
> 7b4f4b5ebceab67ce440a61081a69f0265e17c2a is first bad commit
> diff-tree 7b4f4b5ebceab67ce440a61081a69f0265e17c2a (from 
> 2babf9daae4a3561f3264638a22ac7d0b14a6f52)
> Author: John Heffner <jheffner@psc.edu>
> Date:   Sat Mar 25 01:34:07 2006 -0800
> 
>     [TCP]: Set default max buffers from memory pool size
> 
> Indeed, reverting this patch from 2.6.17-rc1-git4 allows those sites to 
> load again.
> 
> Any ideas?

I'm not seeing this behavior myself.  What are the values of 
/proc/sys/net/ipv4/tcp_wmem, tcp_rmem, and tcp_mem?  How much memory 
does this system have?  (A binary tcpdump might be good, too.)

Thanks,
   -John
