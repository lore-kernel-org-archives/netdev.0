From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 1/8] [I/OAT] DMA memcpy subsystem
Date: Tue, 28 Mar 2006 17:03:09 -0600
Message-ID: <3B202D51-1683-465D-AE3D-DE301017BD69@kernel.crashing.org>
References: <20060311022759.3950.58788.stgit@gitlost.site> <20060311022919.3950.43835.stgit@gitlost.site> <2FF801BB-F96C-4864-AC44-09B4B92531F7@kernel.crashing.org> <c0a09e5c0603281044i57730c66ye08c45aadd352cf8@mail.gmail.com> <D760971F-3C6A-400B-99EA-E95358B37F82@kernel.crashing.org> <c0a09e5c0603281401uaeea6aci57054aef444a5e1@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v746.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Chris Leech" <christopher.leech@intel.com>,
	"linux kernel mailing list" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964791AbWC1XDJ@vger.kernel.org>
In-Reply-To: <c0a09e5c0603281401uaeea6aci57054aef444a5e1@mail.gmail.com>
To: Andrew Grover <andy.grover@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mar 28, 2006, at 4:01 PM, Andrew Grover wrote:

> On 3/28/06, Kumar Gala <galak@kernel.crashing.org> wrote:
>
>>>> Also, what do you think about adding an operation type (MEMCPY,  
>>>> XOR,
>>>> CRYPTO_AES, etc).  We can than validate if the operation type
>>>> expected is supported by the devices that exist.
>>>
>>> No objections, but this speculative support doesn't need to be in  
>>> our
>>> initial patchset.
>>
>> I don't consider it speculative.  The patch is for a generic DMA
>> engine interface.  That interface should encompass all users.  I have
>> a security/crypto DMA engine that I'd like to front with the generic
>> DMA interface today.  Also, I believe there is another Intel group
>> with an XOR engine that had a similar concept called ADMA posted a
>> while ago.
>
> Please submit patches then. We will be doing another rev of the I/OAT
> patch very soon, which you will be able to patch against. Or, once the
> patch gets in mainline then we can enhance it. Code in the Linux
> kernel is never "done", and the burden of implementing additional
> functionality falls on those who want it.

I completely understand that.  However, I think putting something  
into mainline that only works or solves the particular problem you  
have is a bad idea.  I'll provide patches for the changes I'd like to  
see.  However, I figured a little discussion on the subject before I  
went off an spent time on it was worth while.

>> Can you explain what the semantics are.
>>
>> It's been a little while since I posted so my thoughts on the subject
>> are going to take a little while to come back to me :)
>
> Yeah. Basically you register as a DMA client, and say how many DMA
> channels you want. Our net_dma patch for example uses multiple
> channels to help lock contention. Then when channels are available
> (i.e. a DMA device added or another client gives them up) then you get
> a callback. If the channel goes away (i.e. DMA device is removed
> (theoretically possible but practically never happens) or *you* are
> going away and change your request to 0 channels) then you get a
> remove callback.

Do you only get callback when a channel is available?  How do you  
decide to do to provide PIO to the client?

A client should only request multiple channel to handle multiple  
concurrent operations.

> This gets around the problem of DMA clients registering (and therefore
> not getting) channels simply because they init before the DMA device
> is discovered.

What do you expect to happen in a system in which the channels are  
over subscribed?

Do you expect the DMA device driver to handle scheduling of channels  
between multiple clients?

- kumar
