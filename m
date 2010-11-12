From: David Teigland <teigland@redhat.com>
Subject: Re: [PATCH] dlm: Handle application limited situations properly.
Date: Fri, 12 Nov 2010 15:03:33 -0500
Message-ID: <20101112200333.GD11037@redhat.com>
References: <20101110.215639.189706684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ccaulfie@redhat.com, cluster-devel@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101110.215639.189706684.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 10, 2010 at 09:56:39PM -0800, David Miller wrote:
> 
> In the normal regime where an application uses non-blocking I/O
> writes on a socket, they will handle -EAGAIN and use poll() to
> wait for send space.
> 
> They don't actually sleep on the socket I/O write.
> 
> But kernel level RPC layers that do socket I/O operations directly
> and key off of -EAGAIN on the write() to "try again later" don't
> use poll(), they instead have their own sleeping mechanism and
> rely upon ->sk_write_space() to trigger the wakeup.
> 
> So they do effectively sleep on the write(), but this mechanism
> alone does not let the socket layers know what's going on.
> 
> Therefore they must emulate what would have happened, otherwise
> TCP cannot possibly see that the connection is application window
> size limited.
> 
> Handle this, therefore, like SUNRPC by setting SOCK_NOSPACE and
> bumping the ->sk_write_count as needed when we hit the send buffer
> limits.
> 
> This should make TCP send buffer size auto-tuning and the
> ->sk_write_space() callback invocations actually happen.

Thanks, pushed to
git://git.kernel.org/pub/scm/linux/kernel/git/teigland/dlm.git#next
