From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 1/3 v2][NET] gen_estimator: faster gen_kill_estimator
Date: Tue, 22 Jan 2008 06:42:07 -0500
Message-ID: <1201002127.4443.32.camel@localhost>
References: <20080122072152.GA977@ff.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	slavon@bigtelecom.ru, kaber@trash.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:3003 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbYAVLmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 06:42:12 -0500
Received: by py-out-1112.google.com with SMTP id u52so3545524pyb.10
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2008 03:42:11 -0800 (PST)
In-Reply-To: <20080122072152.GA977@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-22-01 at 08:21 +0100, Jarek Poplawski wrote:
> On 22-01-2008 01:29, David Miller wrote:
> ...
> > Fix this right, make a structure like:
> > 
> > struct kernel_gnet_stats_rate_est {
> > 	struct gnet_stats_rate_est	est;
> > 	void				*gen_estimator;
> > }
> > 
> > And update all the code as needed.
> 
> Thanks!
>  I'll try this...

Jarek,

That looks different from the suggestion from Dave.

May i throw in another bone? Theoretically i can see why it would be a
really bad idea to walk 50K estimators every time you delete one - which
is horrible if you are trying to destroy the say 50K of them and gets
worse as the number of schedulers with 50K classes goes up.

But i am wondering why a simpler list couldnt be walked, meaning:

In gen_kill_estimator(), instead of:

for (idx=0; idx <= EST_MAX_INTERVAL; idx++) {

Would deriving a better initial index be a big improvement?
for (e = elist[est->interval].list; e; e = e->next) {


cheers,
jamal

