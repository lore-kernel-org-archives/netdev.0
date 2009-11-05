From: Max Kellermann <mk@cm4all.com>
Subject: Re: [PATCH] tcp: set SPLICE_F_NONBLOCK after first buffer has been
	spliced
Date: Thu, 5 Nov 2009 11:57:49 +0100
Message-ID: <20091105105749.GA4901@rabbit.intern.cm-ag>
References: <20091105095947.32131.99768.stgit@rabbit.intern.cm-ag> <4AF2A929.3000201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, jens.axboe@oracle.com,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753875AbZKEK5k@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AF2A929.3000201@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2009/11/05 11:30, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> I dont think this patch is correct. Could you describe your use case ?

See my second email, there's a demo source.

> If you dont want to block on output pipe, you should set this NONBLOCK 
> flag before calling splice(SPLICE_F_NONBLOCK) syscall.
> 
> ie : Use the socket in blocking mode, but output pipe in non-blocking mode.

Do you think that a splice() should block if the socket is readable
and the pipe is writable according to select()?

"The correct behavior would be to copy as much as possible, and return
without blocking.  Block only if nothing can be transferred."

Do you disagree with that?

> Some application could have a thread working in full blocking mode,
> and have another thread reading the pipe (and eventually unblocking
> first thread)

I don't get this objection.  Please explain.
