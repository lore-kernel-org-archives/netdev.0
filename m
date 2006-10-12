From: "Caitlin Bestler" <caitlin.bestler@gmail.com>
Subject: Re: Suppress / delay SYN-ACK
Date: Thu, 12 Oct 2006 14:58:57 -0700
Message-ID: <469958e00610121458h45581840ke0367647a735c635@mail.gmail.com>
References: <000101c6edd5$a880d430$1a04010a@V505CP> <452E69B2.4030306@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Martin Schiller" <mschiller@tdt.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:13698 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751152AbWJLV66 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 17:58:58 -0400
Received: by nf-out-0910.google.com with SMTP id x30so710453nfb
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2006 14:58:57 -0700 (PDT)
To: "Rick Jones" <rick.jones2@hp.com>
In-Reply-To: <452E69B2.4030306@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/12/06, Rick Jones <rick.jones2@hp.com> wrote:
> Martin Schiller wrote:
> > Hi!
> >
> > I'm searching for a solution to suppress / delay the SYN-ACK packet of a
> > listening server (-application) until he has decided (e.g. analysed the
> > requesting ip-address or checked if the corresponding other end of a
> > connection is available) if he wants to accept the connect request of the
> > client. If not, it should be possible to reject the connect request.
>
> How often do you expect the incomming call to be rejected?  I suspect that would
> have a significant effect on whether the whole thing is worthwhile.
>
> rick jones


More to the point, on what basis would the application be rejecting a
connection request based solely on the SYN?

There are only two pieces of information available: the remote IP
address and port, and the total number of pending requests. The
latter is already addressed through the backlog size, and netfilter
rules can already be used to reject based on IP address.

That would seem to limit the usefullness to scenarios where a given
remote IP address *might* be accepted based on total traffic load,
number of other connections from the same IP address, etc.  If
*all* requests from that IP address are going to be rejected, why
not use netfilter?
