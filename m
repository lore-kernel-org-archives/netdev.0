From: Michael Tuexen <tuexen@fh-muenster.de>
Subject: Re: [PATCH net] net: sctp: stop spamming klog with rfc6458, 5.3.2. deprecation warnings
Date: Wed, 22 Jul 2015 16:46:06 +0200
Message-ID: <C892C0E2-2966-48A8-8C79-88ABEADE8384@fh-muenster.de>
References: <04fbd47379461dc2cb145117a9f81ecc68de7221.1437575142.git.daniel@iogearbox.net>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2102\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: davem@davemloft.net, jhs@mojatatu.com, vyasevic@redhat.com,
	nhorman@tuxdriver.com, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:44113 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965341AbbGVOqJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 10:46:09 -0400
In-Reply-To: <04fbd47379461dc2cb145117a9f81ecc68de7221.1437575142.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 22 Jul 2015, at 16:31, Daniel Borkmann <daniel@iogearbox.net> wrote:
> 
> Back then when we added support for SCTP_SNDINFO/SCTP_RCVINFO from
> RFC6458 5.3.4/5.3.5, we decided to add a deprecation warning for the
> (as per RFC deprecated) SCTP_SNDRCV via commit bbbea41d5e53 ("net:
> sctp: deprecate rfc6458, 5.3.2. SCTP_SNDRCV support"), see [1].
> 
> Imho, it was not a good idea, and we should just revert that message
> for a couple of reasons:
> 
>  1) It's uapi and therefore set in stone forever.
> 
>  2) To be able to run on older and newer kernels, an SCTP application
>     would need to probe for both, SCTP_SNDRCV, but also SCTP_SNDINFO/
>     SCTP_RCVINFO support, so that on older kernels, it can make use
>     of SCTP_SNDRCV, and on newer kernels SCTP_SNDINFO/SCTP_RCVINFO.
>     In my (limited) experience, a lot of SCTP appliances are migrating
>     to newer kernels only ve(ee)ry slowly.
> 
>  3) Some people don't have the chance to change their applications,
>     f.e. due to proprietary legacy stuff. So, they'll hit this warning
>     in fast path and are stuck with older kernels.
> 
> But i.e. due to point 1) I really fail to see the benefit of a warning.
> So just revert that for now, the issue was reported up Jamal.
> 
>  [1] http://thread.gmane.org/gmane.linux.network/321960/
Looks good to me.

Best regards
Michael
> 
> Reported-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Michael Tuexen <tuexen@fh-muenster.de>
> ---
> net/sctp/socket.c | 6 ------
> 1 file changed, 6 deletions(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 1425ec2..17bef01 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -2200,12 +2200,6 @@ static int sctp_setsockopt_events(struct sock *sk, char __user *optval,
> 	if (copy_from_user(&sctp_sk(sk)->subscribe, optval, optlen))
> 		return -EFAULT;
> 
> -	if (sctp_sk(sk)->subscribe.sctp_data_io_event)
> -		pr_warn_ratelimited(DEPRECATED "%s (pid %d) "
> -				    "Requested SCTP_SNDRCVINFO event.\n"
> -				    "Use SCTP_RCVINFO through SCTP_RECVRCVINFO option instead.\n",
> -				    current->comm, task_pid_nr(current));
> -
> 	/* At the time when a user app subscribes to SCTP_SENDER_DRY_EVENT,
> 	 * if there is no data to be sent or retransmit, the stack will
> 	 * immediately send up this notification.
> -- 
> 1.9.3
> 
> 
