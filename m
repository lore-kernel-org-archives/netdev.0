From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] neighbour tables configuration via rtnetlink
Date: Mon, 7 Mar 2005 15:26:22 +0100
Message-ID: <20050307142622.GT31837@postel.suug.ch>
References: <20050305172257.GN31837@postel.suug.ch> <1110202499.1094.1371.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1110202499.1094.1371.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1110202499.1094.1371.camel@jzny.localdomain> 2005-03-07 08:34
> On Sat, 2005-03-05 at 12:22, Thomas Graf wrote:
> The patch overall looks ok although adventerous.
> What is it that requires you to change multiple parameters atomically? I
> cant seem to think of anything. I can see value in seeing some of these
> parameters in user space. Maybe.

Mainly because we have multiple applications that modify neighbour parameters
and they really have need to finish changing all parameters before another
application can look at them again. I solved this with a userspace lockfile
so far but this only catches applications that are aware of the lockfile.
The netlink method still leaves the gap open between fetching the data and
then changing it but that isn't a problem in my case and can be solved with
the netlink daemon for those who care.

> Some of the parameters you are dumping maybe dangerous if they are also
> allowed to be setable. As an example, changing a table name/id etc.
> I think you should review closely again what needs to be exposed.

Sure, not all dumpable parameters will be available for modification but
having them all available in userspace is definitely a good thing.

> I think this is reasonable. However - it is a lot of work. I will have
> no issues with seeing nothing else but netlink (even for ethtool like
> setups). There are certain things that would require more attention than
> others.

Yes, I think so as well but I really want to avoid putting effort into it
and then see it replaced with something else. I think Herbert once thought
about moving some of the rtnetlink stuff into a separate family and
restructuring the whole thing. Still plans there Herbert?

> I was going to write a simple patch to allow setting of indev
> parameters via netlink but havent had time. Started it but havent had
> time to revisit it - if you want to take over that one as well i could
> pass it on to you.

Sure, but I won't have time to actually work on it until next week.

> To achieve distributed configuration you dont need netlink. The main
> advantage of netlink over say /proc is the ability to do async events.
> [Yes, I know i have been shouting for taking netlink and and sending it
> over the wire and mucking around with endianness flags - but after
> practical considerations i am having second thoughts;] 

Yes I went through severeal iterations of thoughts as well but it still
seems reasonable to me. My current approach sounds quite silly but seems
to work out pretty well. It gets down to having libnl providing a XML input
and output interface and XSLT templates to convert every block into byte
order independant form and vice versa. I'm still toying around but I
already managed to convert my XML thingy into other protocols (given they
are at least somehow compatible in architecture). It is also quite simple
to convert these requests into a human readable form such as HTML and
have it placed onto a website for a operator to accept the change or to
simply keep a log of what has been changed when.

I'm not yet sure if it works out in the end but the goal is to reduce the
work needed to support a new rtnetlink object to the existance of a XSLT
stylesheet published somewhere and if possible have the XSLT processor
fetch it automatically from a local or global site. Other advantages?
Operators could modify the XSLT and add conditions and automatically
modify change requests to their needs.
