From: Jiri Pirko <jpirko@redhat.com>
Subject: Question about an assignment in handle_ing()
Date: Mon, 24 May 2010 13:22:36 +0200
Message-ID: <20100524112236.GF2810@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	herbert@gondor.hengli.com.au, kaber@trash.net
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37881 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755456Ab0EXLXG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 May 2010 07:23:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal.

I want to ask you about the following chunk of code of net/core/dev.c in function handle_ing():

2699        if (*pt_prev) {
2700                *ret = deliver_skb(skb, *pt_prev, orig_dev);
2701                *pt_prev = NULL;
2702        } else {
2703                /* Huh? Why does turning on AF_PACKET affect this? */
2704                skb->tc_verd = SET_TC_OK2MUNGE(skb->tc_verd);
2705        }

The assignment (in "else" statement) was added by you here:
http://linux.bkbits.net:8080/linux-2.6.12-stable/?PAGE=cset&REV=40cfc085xjyQLyB1UiTbgaRZSlCN9w

The comment was added after move of this code by Herbert:
http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=f697c3e8b35c18b2698d64137c0fa84b0cdb3d10

Question is if this code is correct here. Maybe I'm missing something but
why is this dependent on a ptype was found previously?

Thanks,

	Jirka
