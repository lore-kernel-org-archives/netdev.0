From: Max Kellermann <mk@cm4all.com>
Subject: Re: [PATCH] tcp: set SPLICE_F_NONBLOCK after first buffer has been
	spliced
Date: Thu, 5 Nov 2009 15:33:20 +0100
Message-ID: <20091105143320.GA22787@rabbit.intern.cm-ag>
References: <20091105095947.32131.99768.stgit@rabbit.intern.cm-ag> <4AF2A929.3000201@gmail.com> <20091105105749.GA4901@rabbit.intern.cm-ag> <4AF2B551.6010302@gmail.com> <20091105132352.GA14453@rabbit.intern.cm-ag> <4AF2DD21.8060604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, jens.axboe@oracle.com,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757357AbZKEOdN@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AF2DD21.8060604@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2009/11/05 15:11, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> It cannot, therefore an application uses O_NDELAY to avoid blocking.
> 
> Try following program if you are not convinced

Indeed, I'm surprised by the result rendered by the Linux kernel.
That however still contradicts with the poll() documentation.

So this boils down to the question: kernel bug or documentation bug?

http://www.opengroup.org/onlinepubs/9699919799/functions/pselect.html

"A descriptor shall be considered ready for writing when a call to an
output function with O_NONBLOCK clear would not block, whether or not
the function would transfer data successfully."

There is no size limit mentioned here.  Your program reveals that the
kernel violates this definition.

> Your patch basically makes SPLICE_F_NONBLOCK option always set
> (choice 1) above)
[...]
> Why in the first place have an option if it is always set ?

It is not, you misunderstood my patch.  If there's no room in the pipe
buffer, then the first iteration of the "while" loop will block (as
usual).  *After* the first iteration has finished (and at least one
buffer has been moved already), the flag is set, and further
iterations will not block.
