From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] Documentation: ptp: Fix build failure on MIPS cross
 builds
Date: Tue, 21 Oct 2014 13:07:25 +0200
Message-ID: <20141021110724.GA16479@netboy>
References: <1413794538-28465-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org, Jonathan Corbet <corbet@lwn.net>,
	netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Markos Chandras <markos.chandras@imgtec.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1413794538-28465-1-git-send-email-markos.chandras@imgtec.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 20, 2014 at 09:42:18AM +0100, Markos Chandras wrote:
> diff --git a/Documentation/ptp/Makefile b/Documentation/ptp/Makefile
> index 293d6c09a11f..397c1cd2eda7 100644
> --- a/Documentation/ptp/Makefile
> +++ b/Documentation/ptp/Makefile
> @@ -1,5 +1,15 @@
>  # List of programs to build
> +ifndef CROSS_COMPILE
>  hostprogs-y := testptp
> +else
> +# MIPS system calls are defined based on the -mabi that is passed
> +# to the toolchain which may or may not be a valid option
> +# for the host toolchain. So disable testptp if target architecture
> +# is MIPS but the host isn't.
> +ifndef CONFIG_MIPS
> +hostprogs-y := testptp
> +endif
> +endif

It seems like a shame to simply give up and not compile this at all.
Is there no way to correctly cross compile this for MIPS?

Thanks,
Richard
