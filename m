From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 1/2] net: Add a test to see if a skb is freeable in
 irq context
Date: Tue, 01 Apr 2014 12:49:47 -0700
Message-ID: <1396381787.3989.12.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	 <87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
	 <20140317.154916.2276987764507311378.davem@davemloft.net>
	 <87iorcgh5d.fsf_-_@xmission.com> <87fvmgf2c7.fsf_-_@xmission.com>
	 <1395149407.22343.8.camel@deadeye.wl.decadent.org.uk>
	 <87lhw7inzg.fsf@nemi.mork.no>
	 <1395156229.9114.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <2c96faab-4293-4e7f-b8e0-4997af745fbf@email.android.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6E02DB@AcuExch.aculab.com>
	 <87mwgbkttv.fsf_-_@x220.int.ebiederm.org>
	 <8761mzktj9.fsf_-_@x220.int.ebiederm.org>
	 <53357681.9050200@cogentembedded.com>
	 <87wqf8j1rx.fsf_-_@x220.int.ebiederm.org>
	 <87r45gj1qf.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	=?ISO-8859-1?Q?=27Bj=F8rn?= Mork' <bjorn@mork.no>,
	Ben Hutchings <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
	"mpm@selenic.com" <mpm@selenic.com>,
	"satyam.sharma@gmail.com" <satyam.sharma@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:60838 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552AbaDATtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 15:49:49 -0400
Received: by mail-pd0-f178.google.com with SMTP id x10so10077252pdj.9
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2014 12:49:49 -0700 (PDT)
In-Reply-To: <87r45gj1qf.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-04-01 at 12:20 -0700, Eric W. Biederman wrote:
> Currently netpoll and skb_release_head_state assume that a skb is
> freeable in hard irq context except when skb->destructor is set.
> 
> The reality is far from this.  So add a function skb_irq_freeable to
> compute the full test and in the process be the living documentation
> of what the requirements are of actually freeing a skb in hard irq
> context.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  include/linux/skbuff.h |   13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 18ef0224fb6a..113fee1b7b63 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2833,6 +2833,19 @@ static inline void skb_init_secmark(struct sk_buff *skb)
>  { }
>  #endif
>  
> +static inline bool skb_irq_freeable(struct sk_buff *skb)
> +{

This probably should be 'const struct sk_buff *skb'

Acked-by: Eric Dumazet <edumazet@google.com>
