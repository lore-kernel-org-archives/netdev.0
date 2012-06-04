From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 3/7] netfilter: nf_ct_helper: implement variable length
 helper private data
Date: Mon, 4 Jun 2012 15:16:11 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1206041513400.16684@frira.zrqbmnf.qr>
References: <1338812485-4232-1-git-send-email-pablo@netfilter.org>  <1338812485-4232-4-git-send-email-pablo@netfilter.org>  <alpine.LNX.2.01.1206041456480.16684@frira.zrqbmnf.qr> <1338815399.8574.10.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([188.40.89.202]:46317 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754099Ab2FDNQM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 09:16:12 -0400
In-Reply-To: <1338815399.8574.10.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 2012-06-04 15:09, Joe Perches wrote:

>On Mon, 2012-06-04 at 15:06 +0200, Jan Engelhardt wrote:
>> On Monday 2012-06-04 14:21, pablo@netfilter.org wrote:
>
>> >@@ -218,13 +221,13 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
>> > 	}
>> > 
>> > 	if (help == NULL) {
>> >-		help = nf_ct_helper_ext_add(ct, flags);
>> >+		help = nf_ct_helper_ext_add(ct, helper, flags);
>> > 		if (help == NULL) {
>> > 			ret = -ENOMEM;
>> > 			goto out;
>> > 		}
>> > 	} else {
>> >-		memset(&help->help, 0, sizeof(help->help));
>> >+		memset(&help->data, 0, sizeof(helper->data_len));
>> > 	}
>> 
>> memset(help->data, 0, sizeof(helper->data_len));
>
>	memset(help->data, 0, helper->data_len);

I knew this looked suspect. With so many "sizeof"s, this spot was 
starting to look like a "mine is bigger" competition.
