From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] Extend netlink error codes
Date: 13 Sep 2004 22:00:23 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095127223.1057.25.camel@jzny.localdomain>
References: <20040910225158.GO20088@postel.suug.ch>
	 <20040911155839.GN4431@wotan.suse.de>
	 <20040911162433.GC21181@postel.suug.ch>
	 <3A0D075D-0423-11D9-BBE1-000A95AD0668@errno.com>
	 <1094937035.2344.189.camel@jzny.localdomain>
	 <20040913203657.GF23686@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sam Leffler <sam@errno.com>, Andi Kleen <ak@suse.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040913203657.GF23686@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-09-13 at 16:36, Thomas Graf wrote:
> * jamal <1094937035.2344.189.camel@jzny.localdomain> 2004-09-11 17:10
> > just reuse skb->cb[] and intepret it in rtnetlink in the case of
> > failures.
> 
> Good idea, however it means to change a lot of APIs used by modules
> to provide the skb or a pointer to the error string buffer.
> 
> I still think it would be best to transport the error code via
> the return value in order to not change any static APIs, but
> I guess that 32bit is not enough to store errno and the id
> your propose below.

The problem with using the return codes is you have to know somehow all
the error variants within netlink code itself. If you return a TLV
skb->cb[] then the netlink code could blindly forward it to user space.
I dont think theres a lot of changes to APIs. the calls from netlink
already pass the skb to all modules. The dumps are speacial since the
->cb[] is actually used.
Of course you could do it with return codes, probably do some smart
things in the netlink code without making it too knowledgeable
but you may need to have a global table.

> Idea: Make user space applications poll on the socket and
> just print the errors async. This would allow netlink users to
> use it for more than just error handling.

I think i agree with what  Dave says in his other email - we should
probably just borrow any useful ideas they have wirthout complicating
things on our part. It does seem too tangential after reading it.

cheers,
jamal
