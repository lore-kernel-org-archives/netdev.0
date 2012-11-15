From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCHv2] sctp: fix /proc/net/sctp/ memory leak
Date: Thu, 15 Nov 2012 13:48:43 -0800
Message-ID: <87k3tmedvo.fsf@xmission.com>
References: <1352987345-11263-1-git-send-email-tt.rantala@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, Dave Jones <davej@redhat.com>
To: Tommi Rantala <tt.rantala@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:38048 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007Ab2KOVs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 16:48:59 -0500
In-Reply-To: <1352987345-11263-1-git-send-email-tt.rantala@gmail.com> (Tommi
	Rantala's message of "Thu, 15 Nov 2012 15:49:05 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tommi Rantala <tt.rantala@gmail.com> writes:

> Commit 13d782f ("sctp: Make the proc files per network namespace.")
> changed the /proc/net/sctp/ struct file_operations opener functions to
> use single_open_net() and seq_open_net().
>
> Avoid leaking memory by using single_release_net() and seq_release_net()
> as the release functions.
>
> Discovered with Trinity (the syscall fuzzer).

Doh!  Thanks for catching this.

Eric

> -	.release = single_release,
> +	.release = single_release_net,
>  };

> -	.release = seq_release,
> +	.release = seq_release_net,
>  };
>  
