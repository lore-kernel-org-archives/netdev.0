From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Sat, 12 Feb 2005 23:32:04 +0100
Message-ID: <20050212223204.GG31837@postel.suug.ch>
References: <1106144009.1047.989.camel@jzny.localdomain> <20050119165421.GB26856@postel.suug.ch> <1106232168.1041.125.camel@jzny.localdomain> <20050120153559.GG26856@postel.suug.ch> <1106576005.1652.1292.camel@jzny.localdomain> <20050124150634.GT23931@postel.suug.ch> <1106747313.1107.7.camel@jzny.localdomain> <1108134446.5523.22.camel@ganymede> <1108215923.1126.132.camel@jzny.localdomain> <1108246033.7554.18.camel@ganymede>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
To: Dan Siemon <dan@coverfire.com>
Content-Disposition: inline
In-Reply-To: <1108246033.7554.18.camel@ganymede>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Dan Siemon <1108246033.7554.18.camel@ganymede> 2005-02-12 17:07
> On Sat, 2005-12-02 at 08:45 -0500, jamal wrote:
> > On first impression, this looks very nice - I think you got the object
> > hierachy figured etc; i will look closely later.
> > What would be really interesting is to see (gulp) a SOAP/xml interface
> > on top of this. Is this something you can do with those "bindings"?
> 
> Yes, a SOAP/XML-RPC interface should be quite possible.  This is one of
> the main reasons I went to the trouble of creating the Mono bindings.  I
> need to create some sort of XML interface to LQL in the next few weeks.

Before you go ahead, please consider its possible usages. If possible
it should conform to an existing format allowing for distributed
configuration of network nodes. If no such thing exist and you design
your own format please consider the following requirements, because it
would be sad if you waste effort that needs to be redone later on.

 - all components of the networking configuration must be configurable.
   This includes links, neighbours, routes, routing rules, traffic
   control but also configuration parameters currently only accessible
   via ethtool.

 - The whole interface must take care of the byte order issues. This is
   the most tricky part.

 - It must be possible to extend it without breaking backward
   compatibility.

> As for combining my work with Thomas, I'm certainly willing to discuss
> it.

So let's discuss it, from what I can see your library only consists of
basic netlink connection abilities and message parsers/builders on a
per netlink user basis. You do not provide any ways to customize it,
if the user of your library wants to send its own messages he's pretty
much on its own because the whole process of constructing the message,
sending it and waiting for the ack is hidden behind one single function.

The per object API is quite similiar, you also let the user set the
attributes to a object and then commit that object to the kernel.

Honestly speaking, your API doesn't fit my needs and the changes to
make it suiteable would be rather big so I'm not sure whether a merge
of my code into yours would make much sense and the only that could be
merged from your side to mine would be the additional support for two
or three qdiscs such as htb.
