From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 10/10] af_unix: use freezable blocking calls in read
Date: Thu, 2 May 2013 17:08:12 -0700
Message-ID: <20130503000812.GY19814@mtj.dyndns.org>
References: <1367458508-9133-1-git-send-email-ccross@android.com>
 <1367458508-9133-11-git-send-email-ccross@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, arve@android.com,
	Oleg Nesterov <oleg@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, netdev@vger.kernel.org
To: Colin Cross <ccross@android.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1367458508-9133-11-git-send-email-ccross@android.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 01, 2013 at 06:35:08PM -0700, Colin Cross wrote:
> Avoid waking up every thread sleeping in read call on an AF_UNIX
> socket during suspend and resume by calling a freezable blocking
> call.  Previous patches modified the freezer to avoid sending
> wakeups to threads that are blocked in freezable blocking calls.
> 
> This call was selected to be converted to a freezable call because
> it doesn't hold any locks or release any resources when interrupted
> that might be needed by another freezing task or a kernel driver
> during suspend, and is a common site where idle userspace tasks are
> blocked.

Heh, so you are aware of the deadlock possibilities.  Good selection
of spots.  For all the conversion patches.

 Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
