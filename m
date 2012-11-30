From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH v2 3/3] pppoatm: protect against freeing of vcc
Date: Thu, 29 Nov 2012 20:38:08 -0500
Message-ID: <201211300138.qAU1c8sE003388@thirdoffive.cmf.nrl.navy.mil>
References: <1354227428.21562.230.camel@shinybook.infradead.org>
Cc: Krzysztof Mazur <krzysiek@podlesie.net>,
	David Laight <David.Laight@ACULAB.COM>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nathan@traverse.com.au
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1354227428.21562.230.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In message <1354227428.21562.230.camel@shinybook.infradead.org>,David Woodhouse writes:
>At this point, I think we're better off as we are (with Krzysztof's
>patch 1/7 dropped, and leaving vcc->dev->ops->close() being called
>before vcc->push(NULL). We've fairly much solved the issues with that
>arrangement, by checking ATM_VF_READY in the protocols' ->push()
>functions.

it isnt clear to me that fixes the race entirely either.
vcc_destroy_socket() and any of the push()/sends()'s are not serialized.
while you may clear the ATM_VF_READY flag, you might not clear it soon
enough for any particular push() that is already running.  so it still
seems like you are racing close() against push() at this point.  the
window is greatly reduced, but it still exists.
