From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: Question about tcp hash function tcp_hashfn()
Date: Fri, 02 Jun 2006 07:40:38 +0200
Message-ID: <87y7wgaze1.fsf@mid.deneb.enyo.de>
References: <20060531090301.GA26782@2ka.mipt.ru>
	<20060531035124.B3065@openss7.org> <20060531105814.GB7806@2ka.mipt.ru>
	<20060531.114127.14356069.davem@davemloft.net>
	<20060601060424.GA28087@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, draghuram@rocketmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Brian F. G. Bidulock" <bidulock@openss7.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.enyo.de ([212.9.189.167]:20669 "EHLO mail.enyo.de")
	by vger.kernel.org with ESMTP id S1750865AbWFBHc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2006 03:32:27 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060601060424.GA28087@2ka.mipt.ru> (Evgeniy Polyakov's message
	of "Thu, 1 Jun 2006 10:04:24 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Evgeniy Polyakov:

> That is wrong. And I have a code and picture to show that, 
> and you dont - prove me wrong :)

Here we go:

static inline num2ip(__u8 a1, __u8 a2, __u8 a3, __u8 a4)
{
	__u32 a = 0;

	a |= a1;
	a << 8;
	a |= a2;
	a << 8;
	a |= a3;
	a << 8;
	a |= a4;

	return a;
}

"gcc -Wall" was pretty illuminating. 8-P After fixing this and
switching to a better PRNG, I get something which looks pretty normal.
