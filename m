From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: 04 Jan 2005 08:19:13 -0500
Message-ID: <1104844753.1085.99.camel@jzny.localdomain>
References: <20050103125635.GB26856@postel.suug.ch>
	 <1104812028.1085.50.camel@jzny.localdomain>
	 <20050104120333.GF26856@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050104120333.GF26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-01-04 at 07:03, Thomas Graf wrote:
> * jamal <1104812028.1085.50.camel@jzny.localdomain> 2005-01-03 23:13

> Right, I changed this already. change/dump/destroy are fully
> optional. Here's the latest API to the classifier:
> 
>  change() (Optional)
>    Called if provided, otherwise ematch api allocates the data, stores
>    it in m->data and sets m->datalen. Special Case: If TCF_EM_SIMPLE
>    is set the ematch data consists of a simple u32 which means no
>    allocation is required and the value is stored in m->data directly.
>
>    Note: I might add a special field to ematch_ops which can be set to
>    the expected length of the ematch data so we have at least some basic
>    sanity check. Thoughts?

My thinking is:
It doesnt have to be simple 32 bit data.
If i pass you a struct and tell you what length it is, then you as the
classifier dont know need to know anything about it. You just store
mystruct as data and datalen from the TLV. you then pass the datastruct
to match() -  Of course the match() will have to know what that struct
means.

>  match() (Must)
>    ...
> 
>  destroy() (Optional)
>    Called if provided, otheriwse m->data is freed in ematch api unless
>    TCF_EM_SIMPLE is set.

Again using the above logic, destroy becomes just kfree(mystruct)

>  dump() (Optional)
>    Called if provided, otherwise m->data is dumped onto the skb with
>    m->datalen as L. Special handling again for TCF_EM_SIMPLE.

and dump becomes a matter of looking at datalen and encapsulating
mystruct in a TLV without thinking about what the content is.

> I think this makes it as simple as it can get while keeping the door
> open for complex ematches such as meta ematch.

Agreed.

> > > Patch 4: Basic Classifier
> > 
> > Very inefficient, but serves the purpose of an example.
> > [Even if you go as basic a hash as fw classifier you will do better]
> 
> Fully agreed, nevertheless I think something like this is
> required to fill the gaps of u32 and fw.

agreed.

cheers,
jamal
