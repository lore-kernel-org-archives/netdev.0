From: gerrit@erg.abdn.ac.uk
Subject: Re: [PATCH 1/1] [QPOLICY]: Ignore packets with specific priority
Date: Fri, 31 Oct 2008 15:51:13 -0000 (GMT)
Message-ID: <56979.148.187.160.35.1225468273.squirrel@148.187.160.35>
References: <200810262233.54649.tomasz@grobelny.oswiecenia.net>
    <20081029052118.GA6412@gerrit.erg.abdn.ac.uk>
    <4909FAEF.8040900@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Gerrit Renker" <gerrit@erg.abdn.ac.uk>,
	"Tomasz Grobelny" <tomasz@grobelny.oswiecenia.net>,
	"Arnaldo Carvalho de Melo" <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: "Tomasz Grobelny" <tomasz@grobelny.oswiecenia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:63889 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751481AbYJaPvn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 11:51:43 -0400
In-Reply-To: <4909FAEF.8040900@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> One difficulty that I see is what to do when the send socket is
>> non-blocking.
>>
> But socket doesn't get into non-blocking mode until specifically
> requested by fcntl(soc, F_SETFL, O_NONBLOCK) call, does it?
>
Yes - the problem is that the code does not stop the user from
setting non-blocking mode on the socket.

>> Maybe purists will not like this since the complexity is now shifted to
>> the
>> user-kernel interface. But it may well be a start to develop some kind
>> of
>> new interface which achieves the same in a cleaner way.
>>
> I think that much of the previously written qpolicy code could be
> removed from the kernel so the interface would be really simple. No
> policy switching, no fancy parameters, etc. The only difference from
> standard interface would be that a packet could have a 'drop me' flag
> (priority 65 in my code). Ok, I agree some may consider it tricky but I
> wouldn't call it complicated. The complicated part is meant to be on the
> userspace side. And that in my opinion has many advantages: easier
> debugging, easier to add new (possibly complex) queuing policies.

I fully agree with the idea, it is the realisation that causes me
some headaches. It would be great if the code need not call send() twice
to send a single packet, and if an skb need not be allocated in order to
create a "waiting effect" in userspace.

The other alternative that I see is to come up with completely new
system calls - as done in SCTP for instance. But this would only make snse
if with the present means things get too ugly; i.e. if the
new semantics can not be expressed with the given system calls.

So there is agreement on the idea, I hope is that realisation
can be refined - without overloading existing calls too much.


>> Can you please narrow down what is happening with CCID-3.  CCID-3 is
>> very
>> complicated and sensitive, so it is possible that the problem is within
>> CCID-3 and not the qpolicy code - need more detailed information.
>>
> On one test it seemed not to work at all in my setup: ccid3 seems not to
> limit traffic at all. But that was just one test so it may well be my
> fault.
>
If you notice anything odd, please do report it on the mailing list.

Gerrit

