From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [Regression] Bonding no longer support tun-interfaces
Date: Mon, 8 Aug 2016 14:21:12 -0700
Message-ID: <20160808212112.GI22974@cork>
References: <20160808211530.GH22974@cork>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: dingtianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34542 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045AbcHHVVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 17:21:19 -0400
Received: by mail-pf0-f175.google.com with SMTP id p64so122831112pfb.1
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 14:21:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160808211530.GH22974@cork>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Redirected by Davem.

Is there a mailing list or a maintainer for regressions?  There used to
be, but I've been out of the loop for a while.

On Mon, Aug 08, 2016 at 02:15:30PM -0700, Jörn Engel wrote:
> This has been reported (and ignored) before:
> http://lkml.iu.edu/hypermail/linux/kernel/1407.2/03790.html
> https://bugzilla.kernel.org/show_bug.cgi?id=89161
> 
> Regression was introduced by:
> 
> commit 00503b6f702e (refs/bisect/bad)
> Author: dingtianhong <dingtianhong@huawei.com>
> Date:   Sat Jan 25 13:00:29 2014 +0800
> 
>     bonding: fail_over_mac should only affect AB mode at enslave and removal processing
>     
>     According to bonding.txt, the fail_over_ma should only affect active-backup mode,
>     but I found that the fail_over_mac could be set to active or follow in all
>     modes, this will cause new slave could not be set to bond's MAC address at
>     enslave processing and restore its own MAC address at removal processing.
>     
>     The correct way to fix the problem is that we should not add restrictions when
>     setting options, just need to modify the bond enslave and removal processing
>     to check the mode in addition to fail_over_mac when setting a slave's MAC during
>     enslavement. The change active slave processing already only calls the fail_over_mac
>     function when in active-backup mode.
>     
>     Thanks for Jay's suggestion.
>     
>     The patch also modify the pr_warning() to pr_warn().
>     
>     Cc: Jay Vosburgh <fubar@us.ibm.com>
>     Cc: Veaceslav Falico <vfalico@redhat.com>
>     Cc: Andy Gospodarek <andy@greyhouse.net>
>     Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Since I never needed bonding or tun-interfaces before, I come late to
> the party.  Some 6k lines have changed in the bonding driver since the
> regression got in two years ago.  So a simple revert is unlikely to lead
> to happiness.
> 
> But I absolutely need that functionality and would rather run a 3.13
> kernel than live with the regression.  dingtianhong, any suggestions?
> 
> Jörn
> 
> --
> It is a cliché that most clichés are true, but then, like most clichés,
> that cliché is untrue.
> -- Stephen Fry

Jörn
