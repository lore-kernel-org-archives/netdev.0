From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: getaddrinfo - should accept IPPROTO_SCTP no?
Date: Sat, 14 Oct 2006 11:59:33 +1300
Message-ID: <5640c7e00610131559n4a3ad8c5x66cf4b72deb57868@mail.gmail.com>
References: <45300564.2050504@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Network Development list" <netdev@vger.kernel.org>,
	"DCCP Mailing List" <dccp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:38723 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751979AbWJMW7i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 18:59:38 -0400
Received: by nf-out-0910.google.com with SMTP id x30so1130882nfb
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2006 15:59:34 -0700 (PDT)
To: "Rick Jones" <rick.jones2@hp.com>
In-Reply-To: <45300564.2050504@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/14/06, Rick Jones <rick.jones2@hp.com> wrote:
> I made some recent changes to netperf to workaround what is IMO a bug in the
> Solaris getaddrinfo() where it will clear the ai_protocol field even when one
> gives it a protocol in the hints.
>
> [If you happen to be trying to use the test-specific -D to set TCP_NODELAY in
> netperf on Solaris, you might want to grab netperf TOT to get this workaround as
> it relates to issues with setting TCP_NODELAY - modulo what it will do to being
> able to run the netperf SCTP tests on Linux...]
>
> In the process though I have stumbled across what appears to be a bug (?) in
> "Linux" getaddrinfo() - returning a -7 EAI_SOCKTYPE if given as hints
> SOCK_STREAM and IPPROTO_SCTP - this on a system that ostensibly supports SCTP.
> I've seen this on RHAS4U4 as well as another less well known distro.
>
> I'm about to see about concocting an additional workaround in netperf for this,
> but thought I'd ask if my assumption - that getaddrinfo() returning -7 when
> given IPPROTO_SCTP - is indeed a bug in getaddrinfo().  Or am I just woefully
> behind in patches or completely offbase on what is correct behaviour for
> getaddrinfo and hints?
>
> FWIW, which may not be much, Solaris 10 06/06 seems content to accept
> IPPROTO_SCTP in the hints.
>
> thanks,
>
> rick jones
> http://www.netperf.org/svn/netperf2/trunk/

In all the DCCP code which has similar issues I just do the protocol
selection on the socket call e.g.
		case TCP:
			new_sock = socket(AF_INET,SOCK_STREAM,0);
			break;
		case DCCP:
			new_sock = socket(AF_INET,SOCK_DCCP,IPPROTO_DCCP);
			break;
		case UDP:
			new_sock = socket(AF_INET,SOCK_DGRAM,0);
			break;

I'm sure you know all this anyway so apologies in advance for telling
you something you probably already know!

We need to come up with a way to select service codes etc for DCCP
which is another parameter needed for a DCCP socket when getaddrinfo
is tidied up.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
