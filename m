From: Dan Siemon <dan@coverfire.com>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Sun, 13 Feb 2005 19:23:37 -0500
Message-ID: <1108340618.14978.66.camel@ganymede>
References: <1106144009.1047.989.camel@jzny.localdomain>
	 <20050119165421.GB26856@postel.suug.ch>
	 <1106232168.1041.125.camel@jzny.localdomain>
	 <20050120153559.GG26856@postel.suug.ch>
	 <1106576005.1652.1292.camel@jzny.localdomain>
	 <20050124150634.GT23931@postel.suug.ch>
	 <1106747313.1107.7.camel@jzny.localdomain>
	 <1108134446.5523.22.camel@ganymede>
	 <1108215923.1126.132.camel@jzny.localdomain>
	 <1108246033.7554.18.camel@ganymede> <20050212223204.GG31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050212223204.GG31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-12-02 at 23:32 +0100, Thomas Graf wrote:
> * Dan Siemon <1108246033.7554.18.camel@ganymede> 2005-02-12 17:07
> > Yes, a SOAP/XML-RPC interface should be quite possible.  This is one of
> > the main reasons I went to the trouble of creating the Mono bindings.  I
> > need to create some sort of XML interface to LQL in the next few weeks.
> 
> Before you go ahead, please consider its possible usages. If possible
> it should conform to an existing format allowing for distributed
> configuration of network nodes. If no such thing exist and you design
> your own format please consider the following requirements, because it
> would be sad if you waste effort that needs to be redone later on.

The initial implementation will be very specific to LQLs methods.  I
need this for a prototype application.

>  - The whole interface must take care of the byte order issues. This is
>    the most tricky part.

I don't see how byte order issues are a problem when using SOAP.
Example?

> > As for combining my work with Thomas, I'm certainly willing to discuss
> > it.
> 
> So let's discuss it, from what I can see your library only consists of
> basic netlink connection abilities and message parsers/builders on a
> per netlink user basis. You do not provide any ways to customize it,
> if the user of your library wants to send its own messages he's pretty
> much on its own because the whole process of constructing the message,
> sending it and waiting for the ack is hidden behind one single function.

My main design goal for LQL is a nice C library for the existing QoS
elements (and later link and friends).  As such public functions that
allow the user of the library to construct their own nlmsg packets is
not my main interest.  The functions in the LQL namespace attempt to
hide all aspects of Netlink and the underlying communication to the
kernel.

However, I do have functions for manipulating raw messages.  These
functions are all in the NL namespace (nl.c and nl.h).  They are quite
purposely hidden from the public API documentation.  Perhaps these
functions should be documented publicly; although for 99% of the people
using the library the last thing they want to do is build a netlink
message.

Examples:
gboolean nl_tcpacket_add_rtattr(TcPacket *pkt, unsigned short type,
	unsigned short len, void *data);
This function adds a new rtattr to the message. There is a similar
function that adds a nested rtattr.

nl_tcpacket_do_command() will send the message and wait for an ACK.

Usage examples can be found in lql_qdisc_htb_helper.c.

> Honestly speaking, your API doesn't fit my needs and the changes to
> make it suiteable would be rather big so I'm not sure whether a merge
> of my code into yours would make much sense and the only that could be
> merged from your side to mine would be the additional support for two
> or three qdiscs such as htb.

I'm curious exactly what your needs are.

It does appear you are aiming for a somewhat more low level library than
I am.  Whether or not that precludes some kind of merger I don't know.

-- 
OpenPGP key: http://www.coverfire.com/files/pubkey.txt
Key fingerprint: FB0A 2D8A A1E9 11B6 6CA3  0C53 742A 9EA8 891C BD98
