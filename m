From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] tuntap: fix error return code in tun_set_iff()
Date: Mon, 22 Apr 2013 23:59:57 -0700
Message-ID: <CAPshTCiLUbZvv3RrwU5GB5L+CW92XoxGGLYRmffHbnG7jWUfzg@mail.gmail.com>
References: <CAPgLHd9WrbgeYH9pw81kQn9sv=On8e399qAOth6MWprF6PS5pg@mail.gmail.com>
	<CAPshTCgApCEsrQ6uFfmyzvNvQNO8-MZ4zJaiMn3pPF+EV7+zJg@mail.gmail.com>
	<5176280F.1060400@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Wei Yongjun <weiyj.lk@gmail.com>,
	David Miller <davem@davemloft.net>, mst@redhat.com,
	Eric Dumazet <edumazet@google.com>, nhorman@tuxdriver.com,
	yongjun_wei@trendmicro.com.cn,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:61444 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753372Ab3DWG77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 02:59:59 -0400
Received: by mail-la0-f46.google.com with SMTP id ep20so245191lab.19
        for <netdev@vger.kernel.org>; Mon, 22 Apr 2013 23:59:58 -0700 (PDT)
In-Reply-To: <5176280F.1060400@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 22, 2013 at 11:19 PM, Jason Wang <jasowang@redhat.com> wrote:
>
> On 04/23/2013 01:37 PM, Jerry Chu wrote:
> > On Fri, Apr 12, 2013 at 6:17 AM, Wei Yongjun <weiyj.lk@gmail.com> wrote:
> >> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> >>
> >> Fix to return a negative error code from the error handling
> >> case instead of 0, as returned elsewhere in this function.
> >>
> >> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> >> ---
> >>  drivers/net/tun.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> >> index b7c457a..729ed53 100644
> >> --- a/drivers/net/tun.c
> >> +++ b/drivers/net/tun.c
> >> @@ -1594,7 +1594,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
> >>
> >>                 if (tun->flags & TUN_TAP_MQ &&
> >>                     (tun->numqueues + tun->numdisabled > 1))
> >> -                       return err;
> >> +                       return -EBUSY;
> > I don't understand - yes it was a brainless bug to return err without
> > setting it!
>
> err was in fact set by tun_attach, so it was always zero here. The code
> works by chance w/o this patch :)

What if tun_attach() returns something > 0?

> > But won't the fix pretty much disable multi-q because only the the creation of
> > the 1st queue will succeed? I thought the intent of "tuntap: fix ambigious
> > multiqueue API" was to "Only allow TUNSETIFF to create queues.".
>
> Yes this patch will break the creation of more than 1 queues.
> >
> > The code is very confusing. (Or am I the one who is confused? Sigh.)
>
> -EBUSY is wrong here, we need return 0 for succeed here. The logic is,
> if we have more than 1 queues attached, no need to re-initialize the net
> device again. Will send patch to correct this.

A comment there will be useful!

Thanks,

Jerry

>
> Thanks.
>
> >
> > Jerry
> >
> >>         }
> >>         else {
> >>                 char *name;
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe netdev" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
