From: jamal <hadi@cyberus.ca>
Subject: Re: Intel and TOE in the news
Date: 21 Feb 2005 09:03:42 -0500
Message-ID: <1108994621.1089.158.camel@jzny.localdomain>
References: <20050220230713.GA62354@muc.de>
	 <200502210332.j1L3WkDD014744@guinness.s2io.com>
	 <20050221115006.GB87576@muc.de>  <20050221132844.GU31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@muc.de>, Leonid Grossman <leonid.grossman@neterion.com>,
        "'rick jones'" <rick.jones2@hp.com>, netdev@oss.sgi.com,
        "'Alex Aizman'" <alex@neterion.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050221132844.GU31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Everything in the stack would have to be re-written not just that one
piece. 
The question is: Is it worth it? My experimentation shows, only in a few
speacilized cases.

cheers,
jamal

On Mon, 2005-02-21 at 08:28, Thomas Graf wrote:
> * Andi Kleen <20050221115006.GB87576@muc.de> 2005-02-21 12:50
> > The main problem is that someone has to go through all the protocol layers
> > and make sure they can process lists. Also it needs careful handling
> > in netfilter.
> 
> Special handling is also required for the ingress qdisc. The classifiers
> or tc_classify() must be changed to iterate over the lists and unlink
> the skbs if one of them is to be dropped. The mirred action must probably
> split the list after cloning the skbs. Given the lists are session based
> all session based qdiscs could benefit from this and enqueue/dequeue the
> lists rather than single skbs. Other qdiscs would have to split the lists
> but could return a new list upon dequeue.
> 
> 
