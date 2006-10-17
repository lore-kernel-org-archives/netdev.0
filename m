From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Linux 2.6.17.14
Date: Tue, 17 Oct 2006 10:41:57 +0200
Message-ID: <20061017084157.GC1742@ff.dom.local>
References: <20061016220426.GA9194@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:28035 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1423167AbWJQIg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 04:36:56 -0400
To: Greg KH <gregkh@suse.de>
Content-Disposition: inline
In-Reply-To: <20061016220426.GA9194@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17-10-2006 00:04, Greg KH wrote:
...
> diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
> index dfb300b..0f42544 100644
> --- a/net/sched/cls_basic.c
> +++ b/net/sched/cls_basic.c
> @@ -197,7 +197,7 @@ static int basic_change(struct tcf_proto
>  	if (handle)
>  		f->handle = handle;
>  	else {
> -		int i = 0x80000000;
> +		unsigned int i = 0x80000000;
>  		do {
>  			if (++head->hgenerator == 0x7FFFFFFF)
>  				head->hgenerator = 1;

		} while (--i > 0 && basic_get(tp, head->hgenerator));

		if (i <= 0) {
...

I know it should be seen earlier but maybe somebody
should make it less funny at a next chance:

		if (i == 0) {
 
Jarek P.
