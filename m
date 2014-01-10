From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 3/4] net: make tcp_cleanup_rbuf private
Date: Fri, 10 Jan 2014 10:38:40 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D4579D9@AcuExch.aculab.com>
References: <20140109201642.28381.82141.stgit@viggo.jf.intel.com>
	<CADVnQy=Tk68y217cbw7O5apCJV+eOmKMqLNbgAZRa_cxUArdKg@mail.gmail.com>
	<CAPcyv4hPnCud=MWpsCMNZmK_BwVV8WZHOs7=GQMhymgkv-gNkw@mail.gmail.com>
 <20140109.154232.65818281679170677.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "ncardwell@google.com" <ncardwell@google.com>,
	"dmaengine@vger.kernel.org" <dmaengine@vger.kernel.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"kaber@trash.net" <kaber@trash.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>,
	"dan.j.williams@intel.com" <dan.j.williams@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140109.154232.65818281679170677.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller
...
> > On Thu, Jan 9, 2014 at 12:26 PM, Neal Cardwell <ncardwell@google.com> wrote:
> >> On Thu, Jan 9, 2014 at 3:16 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> >>> net_dma was the only external user so this can become local to tcp.c
> >>> again.
> >> ...
> >>> -void tcp_cleanup_rbuf(struct sock *sk, int copied)
> >>> +static void cleanup_rbuf(struct sock *sk, int copied)
> >>
> >> I would vote to keep the tcp_ prefix. In the TCP code base that is the
> >> more common idiom, even for internal/static TCP functions, and
> >> personally I find it easier to read and work with in stack traces,
> >> etc. My 2 cents.
> >>
> >
> > Ok.  It was cleanup_rbuf() in a former life, but one vote for leaving
> > the name as is is enough for me.
> 
> You can make that two votes :)

I suspect DM adds 2000 votes :-)

Keeping the prefix makes it easier to grep for, and makes it more
obvious that it isn't a generic function (when being called).

	David
