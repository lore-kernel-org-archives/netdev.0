From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Intel and TOE in the news
Date: Mon, 21 Feb 2005 16:34:43 +0100
Message-ID: <20050221153443.GW31837@postel.suug.ch>
References: <20050220230713.GA62354@muc.de> <200502210332.j1L3WkDD014744@guinness.s2io.com> <20050221115006.GB87576@muc.de> <20050221132844.GU31837@postel.suug.ch> <1108994621.1089.158.camel@jzny.localdomain> <20050221141714.GV31837@postel.suug.ch> <1108996313.1090.178.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@muc.de>, Leonid Grossman <leonid.grossman@neterion.com>,
        "'rick jones'" <rick.jones2@hp.com>, netdev@oss.sgi.com,
        "'Alex Aizman'" <alex@neterion.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1108996313.1090.178.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1108996313.1090.178.camel@jzny.localdomain> 2005-02-21 09:31
> 
> I have done the experiments and even posted the patches on netdev last
> year to batch on enqueue. 

Right, I slightly remember. I have a head like a sieve. Can you
remmeber the subject of the post? I can't find it in the archive.

> Despite Andis assertion that theres value in amortizing the locks, the
> benefits are highly missing on a generic level unfortunately.
> Locking overhead is like the 50th item on things you have to worry about
> - so i wouldnt even start worrying about this. 

OK.

> Infact performance goes down when you batch in some cases depending on
> the hardware used. My investigation shows that if you have a fast CPU
> and a fast bus, theres always only one packet in flight within the
> stack. Batching by definition requires more than one packet.

Make sense but we probably have multiple packets in the stack if qdiscs are
involved. What bottlenecks remain in that case? One is probably
transmission not being able to keep up because receiving is using too much
resources The transmitter dropping packets making the bottleneck
even worse. Can we reduce the dropping by pushing multiple skbs to the nic
by for example have dequeue return a batch of skbs?
