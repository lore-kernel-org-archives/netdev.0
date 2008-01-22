From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/3 v2][NET] gen_estimator: faster gen_kill_estimator
Date: Tue, 22 Jan 2008 13:29:27 +0100
Message-ID: <20080122122927.GE2079@ff.dom.local>
References: <20080122072152.GA977@ff.dom.local> <1201002127.4443.32.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	slavon@bigtelecom.ru, kaber@trash.net
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.188]:24780 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbYAVMWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 07:22:52 -0500
Received: by fk-out-0910.google.com with SMTP id z23so1713310fkz.5
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2008 04:22:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1201002127.4443.32.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 22, 2008 at 06:42:07AM -0500, jamal wrote:
...
> Jarek,
> 
> That looks different from the suggestion from Dave.

Hmm..., I'm not sure you mean my or your suggestion here, but you
are right anyway...

> May i throw in another bone? Theoretically i can see why it would be a
> really bad idea to walk 50K estimators every time you delete one - which
> is horrible if you are trying to destroy the say 50K of them and gets
> worse as the number of schedulers with 50K classes goes up.
> 
> But i am wondering why a simpler list couldnt be walked, meaning:
> 
> In gen_kill_estimator(), instead of:
> 
> for (idx=0; idx <= EST_MAX_INTERVAL; idx++) {
> 
> Would deriving a better initial index be a big improvement?
> for (e = elist[est->interval].list; e; e = e->next) {

Maybe I miss something, but there still could be a lot of this walking
and IMHO any such longer waiting with BHs disabled is hard to accept
with current memory sizes and low-latencies prices. And currently time
seems to be even more precious here: RCU can't even free any
gen_estimator memory during such large qdisc with classes deletion.

Thanks,
Jarek P.
