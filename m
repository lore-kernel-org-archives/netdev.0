From: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: nfs client hang
Date: Wed, 28 Jul 2010 13:37:20 -0400
Message-ID: <4C506AD0.4070608@oracle.com>
References: <99613C19B13C5D40914FB8930657FA9303365708DE@uk-ex-mbx1.terastack.bluearc.com>	 <4C4E89D4.8040607@bluearc.com>	 <ABFC24E4C13D81489F7F624E14891C8607DDF8D1E4@uk-ex-mbx1.terastack.bluearc.com> <1280233276.2827.175.camel@edumazet-laptop> <4C4F174C.2000308@oracle.com> <ABFC24E4C13D81489F7F624E14891C8607DDF8D3D0@uk-ex-mbx1.terastack.bluearc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Linux Kernel Mailing List (linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org)"
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Chittenden <andyc-Pe6u2o1+k2hBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <ABFC24E4C13D81489F7F624E14891C8607DDF8D3D0-yEvK6Dt055VEbG1eAH4Z+rwY7bzXMFrTPsgEledslx8@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/28/10 03:24 AM, Andy Chittenden wrote:
> resending as it seems to have been corrupted on LKML!
>
>> The RPC client marks the socket closed. and the linger timeout is
>> cancelled.  At this point, sk_shutdown should be set to zero, correct?
>> I don't see an xs_error_report() call here, which would confirm that the
>> socket took a trip through tcp_disconnect().
>
> From my reading of tcp_disconnect(), it calls sk->sk_error_report(sk)
> unconditionally so as there's no xs_error_report(), that surely means
> the exact opposite: tcp_disconnect() wasn't called. If it's not
> called, sk_shutdown is not cleared. And my revised tracing confirmed
> that it was set to SEND_SHUTDOWN.

Sorry, that's what I meant above.

An xs_error_report() debugging message at that point in the log would 
confirm that the socket took a trip through tcp_disconnect().  But I 
don't see such a message.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
