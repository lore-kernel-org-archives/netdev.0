From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: setting ICSK_CA_PRIV_SIZE larger than 16 * sizeof(u32)
Date: Fri, 27 Jun 2008 14:32:58 -0700
Message-ID: <20080627143258.173120cd@extreme>
References: <965f530d0806270137y19c36638yc6ae0a1d4bfa63e7@mail.gmail.com>
	<20080627.023046.193703830.davem@davemloft.net>
	<965f530d0806271420y7ffebd40xb9b2f9a035206932@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Kiran Kotla" <kotlakiran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:41644 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753136AbYF0VdG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 17:33:06 -0400
In-Reply-To: <965f530d0806271420y7ffebd40xb9b2f9a035206932@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Jun 2008 16:20:10 -0500
"Kiran Kotla" <kotlakiran@gmail.com> wrote:

> Hi david,
> 
> Thank you very much for your response. I am new to this forum and not
> sure if I could include you in my reply.
> 
> Well, we tried our best to reduce the size of our private variables.
> 
> The major consumers of space however are two arrays of 32 bit integers
> each of size '8', which are used to estimate drop probability and
> early congestion response probability (our protocol specific), which
> cannot be reduced to be 16 bit integers and further the size of the
> array cannot be reduced to some value lesser without degrading the
> estimation of drop probability.
> 
> I guess the only way left is to have a trade-off between the
> performance of our protocol and size of the array.
> 
> In any case, I was wondering if still there is a way to increase the
> size of the blob, though we would not to increase the size of blob to
> get our protocol running in the kernel.
> 
> Thanks again!
> Kiran

If need be you can use a pointer to an allocated array for that (it would be
up to your code to free it).  You might even want to make this per route
rather than per socket. That would require lookup/locking/ref counting, but
it would allow sharing path information when multiple sockets along same
path are present.
