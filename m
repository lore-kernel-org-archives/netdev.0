From: "Ulrich Drepper" <drepper@gmail.com>
Subject: Re: [take19 0/4] kevent: Generic event handling mechanism.
Date: Tue, 3 Oct 2006 21:50:09 -0700
Message-ID: <a36005b50610032150x8233feqe556fd93bcb5dc73@mail.gmail.com>
References: <115a6230591036@2ka.mipt.ru> <11587449471424@2ka.mipt.ru>
	 <20060927150957.GA18116@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>,
	"Ulrich Drepper" <drepper@redhat.com>,
	"Andrew Morton" <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	"Zach Brown" <zach.brown@oracle.com>,
	"Christoph Hellwig" <hch@infradead.org>,
	"Chase Venters" <chase.venters@clientec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:47746 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1030278AbWJDEuK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 00:50:10 -0400
Received: by ug-out-1314.google.com with SMTP id o38so13507ugd
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2006 21:50:09 -0700 (PDT)
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
In-Reply-To: <20060927150957.GA18116@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/27/06, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
\> I have been told in private what is signal masks about - just to wait
> until either signal or given condition is ready, but in that case just
> add additional kevent user like AIO complete or netwrok notification
> and wait until either requested events are ready or signal is triggered.

No, this won't work.  Yes, I want signal notification as part of the
event handling.  But there are situations when this is not suitable.
Only if the signal is expected in the same code using the event
handling can you do this.  But this is not always possible.
Especially when the signal handling code is used in other parts of the
code than the event handling.  E.g., signal handling in a library,
event handling in the main code.  You cannot assume that all the code
is completely integrated.
