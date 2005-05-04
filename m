From: jamal <hadi@cyberus.ca>
Subject: Re: patch: Action repeat
Date: Wed, 04 May 2005 07:46:34 -0400
Message-ID: <1115207194.7665.109.camel@localhost.localdomain>
References: <4273BBAA.6060405@trash.net>
	 <1114882045.8929.123.camel@localhost.localdomain>
	 <4273CAB7.6080403@trash.net>
	 <1114890709.8929.147.camel@localhost.localdomain>
	 <20050430200848.GF577@postel.suug.ch>
	 <1114894202.8929.165.camel@localhost.localdomain>
	 <20050430215550.GH577@postel.suug.ch>
	 <1114900485.8929.171.camel@localhost.localdomain>
	 <20050430235809.GI577@postel.suug.ch>
	 <1115035838.8929.236.camel@localhost.localdomain>
	 <20050502150632.GM577@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050502150632.GM577@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-02-05 at 17:06 +0200, Thomas Graf wrote:
> * jamal <1115035838.8929.236.camel@localhost.localdomain> 2005-05-02 08:10
[..]
> > I am beginning to think that perhaps classid should stay as a local
> > scope metadata and what Patrick suggested maybe the way out. Although i
> > have to admit I dont like a generic function to have a parameter that
> > only a very small set of users find useful. If we are going to allow a
> > structure to be passed back and forth, perhaps it should also carry
> > other things (in addition to _result). Need to think a little.
> 
> What about if we introduce something like struct tcf_pkt_info as we
> have it for ematches? I'm using it intensly to share information
> from the classifier to ematches to extend and customize existing
> classifier. 

Basically, something along those lines (eg struct tca_pkt_info) in which
the tcf_result is one of the components should do it. 

I would be satisfied with this being the structure in the ->act()
parameters because then it could also be used to pass action-metadata
around (no action written so far needs such coordination, but its been
one of those things i have been thinking of for some dynamic creations
for example  where the return code is insufficient to describe things).
Patrick, either you or i could do it. It doesnt matter if at the moment
the structure only contains tcf_result or elements of tcf_result because
i will add more to it later. Then we could kill access to tc_classid in
exec()

> We could declare tc_classid as being global by definition
> and hide the current use in the API? I'd really like to be able to
> transfer classification results from one device to another.

since tc_classid suddenly becomes available theres no question about the
need for it being global - which is selectable at the meta action.

Global I believe means you dont reset it when you clone/copy.
skb->tc_verd is only cleared when we free the skb at the moment and
transfered when we clone or copy. A bit or two could be reserved in the
tc_verd to say "clear tc_classid" and have the meta action decide if it
is global(dont clear) or not(clear - current behavior) during
clone/copy . Does this sound reasonable?
 
cheers,
jamal
