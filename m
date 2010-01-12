From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH 1/2] net: tcp_header_len_th and tcp_option_len_th
Date: Tue, 12 Jan 2010 12:42:04 -0500
Message-ID: <4B4CB46C.8020502@gmail.com>
References: <4B44FE3C.6060809@gmail.com> <4B450065.4010108@gmail.com> <4B4C519E.2090207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754439Ab0ALRmL@vger.kernel.org>
In-Reply-To: <4B4C519E.2090207@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Its better to inline your patches so that we can comment them, without copy/paste
> 
> When I hit 'reply to', my mailer only quoted the ChangeLog, not the patch.
> 
Seeing that we're both using Mozilla, how to you do it?

It took me many attempts to get this to work with Thunderbird on the Mac.


> Anyway ..
> 
> +/* Length of standard options only.  This could be negative. */
> +static inline int tcp_option_len_th(const struct tcphdr *th)
> +{
> +	return (int)(th->doff * 4) - sizeof(*th);
> +}
> 
> 
> The (int) cast is not necessary, since the function returns a signed int
> 
> ->
> 	return th->doff * 4 - sizeof(*th);
> 
Then GCC must be smarter than it was in the past, as doff is an __u16
bit slice -- once upon a time, a cast was required before subtraction.
One of the dis/advantages of C programming for 30+ years is that my
fingers remember some fairly old practices....

(But this still works properly!)
