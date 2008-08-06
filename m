From: jamal <hadi@cyberus.ca>
Subject: Re: few more fixes for iproute2/m_ipt
Date: Wed, 06 Aug 2008 06:04:45 -0400
Message-ID: <1218017085.4755.23.camel@localhost>
References: <200808060042.53503.denys@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:27998 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbYHFKEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 06:04:49 -0400
Received: by an-out-0708.google.com with SMTP id d40so492758and.103
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2008 03:04:49 -0700 (PDT)
In-Reply-To: <200808060042.53503.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys,

On Wed, 2008-06-08 at 00:42 +0300, Denys Fedoryshchenko wrote:
> Comments:
> 1)optind according iptables sources have to be set to 0. If it is set to 1, in 
> batch it will mess up things. Also in iptables sources i notice that ->tflags 
> and ->used need to be reset.

Indeed there seems to be an issue here, but:
Have you tried in your batch with a few "index"ed parameters to ipt with
your fix? I think it will break with your changes. Of course that does
not invalidate your concern. If you send me a two liner batch example
which breaks for you, I will test it.

> 2)Since target->t = fw_calloc(1, size); allocated memory in function build_st, 
> it have to be freed at the end, or in batch we will have memory leak. TODO: 
> Probably it must be freed in all "return -1" cases in parse_ipt after 
> build_st. About this i am not sure, up to Stephen.
> 
> 3)lname and new_name was malloc'ed, but not freed
> 
> Point 1 fix is critical, since without it m_ipt crashing iproute2 in batch 
> mode.

I think #2 and #3 are leggit. Send two patches - one for #1 when you
validate and the other for #2,#3 when you validate. BTW, for the
equivalent of the latter - if you feel brave - theres a lot more of that
type in the tc code.

cheers,
jamal

