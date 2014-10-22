From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCHv4 3/4] sparc64: Avoid irqsave/restore on vio.lock if
 in_softirq()
Date: Tue, 21 Oct 2014 20:16:12 -0400
Message-ID: <20141022001612.GB26724@oracle.com>
References: <20141021141647.GF15405@oracle.com>
 <CAGRGNgXvKJBhOE1z3=_gZkE=X94HnoAvTN6Zv5G1h8JuFfS8Ng@mail.gmail.com>
 <5446F291.1030400@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julian Calaby <julian.calaby@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	sparclinux <sparclinux@vger.kernel.org>
To: Dave Kleikamp <dave.kleikamp@oracle.com>
Return-path: <sparclinux-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5446F291.1030400@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (10/21/14 18:56), Dave Kleikamp wrote:
> > 
> > Is gcc not smart enough to know that this variable isn't used before
> > it's set? (I assume it isn't used elsewhere in this function)
> 
> It probably assumes in_softirq() might evaluate differently in the each
> case.

yes, that's what I suspected too. I suppose it is possible
from the compiler's point of view that something in between 
might change the result of in_softirq() so that we may be 
using an uninit variable in the second call.

anyway, the warning was annoying, and would only numb the
user into ignoring other real issues, so I figured I might
as well silence the warning.

--Sowmini

