From: Donald Becker <becker@scyld.com>
Subject: Re: ifconfig TX/RX errors
Date: Wed, 13 Nov 2002 11:45:02 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0211131127510.1024-100000@beohost.scyld.com>
References: <Pine.GSO.4.30.0211082056180.16360-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <Pine.GSO.4.30.0211082056180.16360-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 8 Nov 2002, jamal wrote:
> On Fri, 8 Nov 2002, Donald Becker wrote:
> > On Fri, 8 Nov 2002, Cheng Jin wrote:
> >
> > > What does a large number of RX/TX errors from ifconfig output generally
> > > mean?  Does it also include drop/overruns/frame errors?
> >
> > The 'ifconfig' program doesn't have a defined behavior.  It reads
> > /proc/net/dev and sums some of the available error counts.  You should
> > read /proc/net/dev directly to find out what is going wrong.
> >
> 
> Actually, unbelievable as it may sound, the ifconfig data
> matches SNMP stats as defined in RFC1213 interfaces table;
> same with things like netstat -s in the tcp data etc

Are you certain about that Jamal?  This is /proc/net/dev numbers
covering the network interface device layer, not the protocol layers,
The numbers Linux 'ifconfig' reports are similar, but not the same as
the very limited counts that the old BSDs used.

When I wrote the /proc/net/dev statistics count output, I unwisely
summarized some of the independent fields the drivers recorded to fit
into an 79 column output(1).  I should have output all of the
statistics, and let user-level programs summarize as they saw fit.
Even today there is no way to get out the individual numbers.

(1) That effort at human readability was discarded when new fields
were added, making the output incompatible with earlier versions of
ifconfig.  So now the output is longer than a line, but it still
doesn't break out the important error counts.  

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
