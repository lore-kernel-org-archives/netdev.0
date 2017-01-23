From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 3/4] sctp: add support for generating stream
 reconf add incoming/outgoing streams request chunk
Date: Mon, 23 Jan 2017 10:58:10 -0500 (EST)
Message-ID: <20170123.105810.222331205902181203.davem@davemloft.net>
References: <063D6719AE5E284EB5DD2968C1650D6DB026900F@AcuExch.aculab.com>
        <20170120163921.GU3781@localhost.localdomain>
        <063D6719AE5E284EB5DD2968C1650D6DB026B8E0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcelo.leitner@gmail.com, lucien.xin@gmail.com,
        netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        nhorman@tuxdriver.com, vyasevich@gmail.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42628 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750738AbdAWP6M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 10:58:12 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB026B8E0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Mon, 23 Jan 2017 12:26:12 +0000

> From: Marcelo Ricardo Leitner > Sent: 20 January 2017 16:39
>> To: David Laight
>> On Fri, Jan 20, 2017 at 02:50:01PM +0000, David Laight wrote:
>> > From: Xin Long
>> > > Sent: 19 January 2017 17:19
>> > > This patch is to define Add Incoming/Outgoing Streams Request
>> > > Parameter described in rfc6525 section 4.5 and 4.6. They can
>> > > be in one same chunk trunk as rfc6525 section 3.1-7 describes,
>> > > so make them in one function.
>> > ...
>> > > +struct sctp_strreset_addstrm {
>> > > +	sctp_paramhdr_t param_hdr;
>> > > +	__u32 request_seq;
>> > > +	__u16 number_of_streams;
>> > > +	__u16 reserved;
>> > > +} __packed;
>> > ...
>> > > +		addstrm.param_hdr.type = SCTP_PARAM_RESET_ADD_OUT_STREAMS;
>> > > +		addstrm.param_hdr.length = htons(size);
>> > > +		addstrm.number_of_streams = htons(out);
>> > > +		addstrm.request_seq = htonl(asoc->strreset_outseq);
>> > > +		addstrm.reserved = 0;
>> > > +
>> > > +		sctp_addto_chunk(retval, size, &addstrm);
>> >
>> > Since you allocate the sctp_strreset_addstrm structure on stack
>> > there is no requirement for it to be packed.
>> 
>> It shouldn't matter that it's allocated on stack. Why should it?
>> We need it to be packed as this is a header that will be sent out to
>> another peer, so there can't be any padding on it.
> 
> That isn't what __packed means.
> It means that the compiler must assume that the structure can be
> misaligned in memory and must use byte memory accesses on systems
> that fault misaligned memory accesses.

Also, for the types involved there will not be any padding at all.
Check if you do not believe me.

If this is "so critical" for end to end communication, why the heck
do you not see __packed sprinkled all over our definitions for IPV4,
IPV6, TCP, UDP, etc. headers?

Do you know why?  Because it's completely unnecessary...

Can I seriously, strongly, state that people should use __packed as
the last possible resort when writing code?

Don't add it unless you run into a problem which fundamentally cannot
be solved by either using different data types, a different ordering
of data items, or similar.

And when __packed is actually legitimate and used I am now going to
require a HUGE FRIGGIN' COMMENT explaining why no other approach
whatsoever can solve the problem.

__packed is going to emit incredibly inefficient code on some cpus,
I really don't think people truly understand the enormous negative
ramifications of using __packed.

It is almost never, ever, necessary.

And I'm tired of writing this tirade every half year or so.

__packed, just say no...
