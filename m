From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: padata - is serial actually serial?
Date: Wed, 15 Jun 2016 13:52:03 +0200
Message-ID: <20160615115203.GB7698@gauss.secunet.com>
References: <CAHmME9qnufO90qF7v9bVb7L+6KQA=kaZ=BML2sRwzbQHtFLJGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-crypto@vger.kernel.org>, Netdev <netdev@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:58748 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752984AbcFOLwK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 07:52:10 -0400
Content-Disposition: inline
In-Reply-To: <CAHmME9qnufO90qF7v9bVb7L+6KQA=kaZ=BML2sRwzbQHtFLJGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jason.

On Tue, Jun 14, 2016 at 11:00:54PM +0200, Jason A. Donenfeld wrote:
> Hi Steffen & Folks,
> 
> I submit a job to padata_do_parallel(). When the parallel() function
> triggers, I do some things, and then call padata_do_serial(). Finally
> the serial() function triggers, where I complete the job (check a
> nonce, etc).
> 
> The padata API is very appealing because not only does it allow for
> parallel computation, but it claims that the serial() functions will
> execute in the order that jobs were originally submitted to
> padata_do_parallel().
> 
> Unfortunately, in practice, I'm pretty sure I'm seeing deviations from
> this. When I submit tons and tons of tasks at rapid speed to
> padata_do_parallel(), it seems like the serial() function isn't being
> called in the exactly the same order that tasks were submitted to
> padata_do_parallel().
> 
> Is this known (expected) behavior? Or have I stumbled upon a potential
> bug that's worthwhile for me to investigate more?

It should return in the same order as the job were submitted,
given that the submitting cpu and the callback cpu are fixed
for all the jobs you want to preserve the order.  If you submit
jobs from more than one cpu, we can not know in which order
they are enqueued. The cpu that gets the lock as the first
has its job in front. Same if you use more than one callback cpu
we can't know in which order they are dequeued, because the
serial workers are scheduled independent on each cpu.

I use it in crypto/pcrypt.c and I never had problems.
