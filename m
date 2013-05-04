From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH v2 10/10] af_unix: use freezable blocking calls in read
Date: Sat, 04 May 2013 21:19:49 +0200
Message-ID: <85487641.pdFCOjE3G7@vostro.rjw.lan>
References: <1367458508-9133-1-git-send-email-ccross@android.com> <1367458508-9133-11-git-send-email-ccross@android.com> <20130503000812.GY19814@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: Colin Cross <ccross@android.com>, linux-pm@vger.kernel.org,
	linux-kernel@vger.kernel.org, arve@android.com,
	Oleg Nesterov <oleg@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20130503000812.GY19814@mtj.dyndns.org>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, May 02, 2013 05:08:12 PM Tejun Heo wrote:
> On Wed, May 01, 2013 at 06:35:08PM -0700, Colin Cross wrote:
> > Avoid waking up every thread sleeping in read call on an AF_UNIX
> > socket during suspend and resume by calling a freezable blocking
> > call.  Previous patches modified the freezer to avoid sending
> > wakeups to threads that are blocked in freezable blocking calls.
> > 
> > This call was selected to be converted to a freezable call because
> > it doesn't hold any locks or release any resources when interrupted
> > that might be needed by another freezing task or a kernel driver
> > during suspend, and is a common site where idle userspace tasks are
> > blocked.
> 
> Heh, so you are aware of the deadlock possibilities.  Good selection
> of spots.  For all the conversion patches.
> 
>  Acked-by: Tejun Heo <tj@kernel.org>

I wonder if that includes [3/10] (just to get the record straight)?

Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
