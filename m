From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH][RFC] Infrastructure for out-of-band parameter passing
Date: Tue, 8 Jun 2010 08:31:20 -0700
Message-ID: <20100608083120.e92a7739.rdunlap@xenotime.net>
References: <20100608003049.GA29350@dvomlehn-lnx2.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: to@dvomlehn-lnx2.corp.sa.net, netdev@vger.kernel.org
To: David VomLehn <dvomlehn@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([72.52.115.56]:59786 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752239Ab0FHPb0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jun 2010 11:31:26 -0400
Received: from chimera.site ([71.245.98.113]) by xenotime.net for <netdev@vger.kernel.org>; Tue, 8 Jun 2010 08:31:21 -0700
In-Reply-To: <20100608003049.GA29350@dvomlehn-lnx2.corp.sa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Jun 2010 17:30:49 -0700 David VomLehn wrote:

> Infrastructure to support out of band/indirect passing of data to functions.
> 
> It is useful at times to be able to pass data from one function to another
> nested many stack frames more deeply than the passing function. Doing so
> allows the interfaces in the intervening functions to be simpler, though
> this "hidden" information passing risks increased complexity. In cases
> where this is justified, this simple infrastructure provides the
> functionality.
> 
> Out of band data passing is implemented by adding, for each instance,
> an element to the task_struct that serves as the pointer to the top
> of a OOB parameter stack. Data is made available by being pushed
> on the OOB parameter stack by a function, and accessed via the top
> element of the OOB parameter stack.
> 
> Signed-off-by: David VomLehn (dvomlehn@cisco.com)
> ---
>  include/linux/oobparam.h |   89 ++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 89 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/oobparam.h b/include/linux/oobparam.h
> new file mode 100644
> index 0000000..6eaa04c
> --- /dev/null
> +++ b/include/linux/oobparam.h
> @@ -0,0 +1,89 @@
...
> +
> +/**
> + * oobparam_push - push an out of band parameter frame on the OOB param stack
> + * @head	Pointer to the OOB parameter stack top, which must be in the
> + *		task structure.
> + * @frame	Pointer to the OOB parameter frame, generally embedded in
> + *		another structure

Need a colon ':' after the parameter names for kernel-doc notation:

 * @head:
 * @frame:

See Documentation/kernel-doc-nano-HOWTO.txt for info or ask me if you have
problems or questions.

Thanks.

> + */
> +static inline void oobparam_push(struct oobparam *top, struct oobparam *frame)
> +{
> +	frame->next = top;
> +	/* We need to ensure that the pointer in the frame is set prior to
> +	 * the pointer to the top in case we handle an interrupt in between
> +	 * the two stores. */
> +	wmb();
> +	top->next = frame;
> +}


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
