From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 1/8] [I/OAT] DMA memcpy subsystem
Date: Tue, 28 Mar 2006 12:58:57 -0600
Message-ID: <D760971F-3C6A-400B-99EA-E95358B37F82@kernel.crashing.org>
References: <20060311022759.3950.58788.stgit@gitlost.site> <20060311022919.3950.43835.stgit@gitlost.site> <2FF801BB-F96C-4864-AC44-09B4B92531F7@kernel.crashing.org> <c0a09e5c0603281044i57730c66ye08c45aadd352cf8@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v746.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Chris Leech" <christopher.leech@intel.com>,
	"linux kernel mailing list" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751255AbWC1S64@vger.kernel.org>
In-Reply-To: <c0a09e5c0603281044i57730c66ye08c45aadd352cf8@mail.gmail.com>
To: Andrew Grover <andy.grover@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mar 28, 2006, at 12:44 PM, Andrew Grover wrote:

> On 3/16/06, Kumar Gala <galak@kernel.crashing.org> wrote:
>> It would seem that when a client registers (or shortly there after
>> when they call dma_async_client_chan_request()) they would expect to
>> get the number of channels they need by some given time period.
>>
>> For example, lets say a client registers but no dma device exists.
>> They will never get called to be aware of this condition.
>>
>> I would think most clients would either spin until they have all the
>> channels they need or fall back to a non-async mechanism.
>
> Clients *are* expected to fall back to non-async if they are not given
> channels. The reason it was implemented with callbacks for
> added/removed was that the client may be initializing before the
> channels are enumerated. For example, the net subsystem will ask for
> channels and not get them for a while, until the ioatdma PCI device is
> found and its driver loads. In this scenario, we'd like the net
> subsystem to be given these channels, instead of them going unused.

Fair, I need to think on that a little more.

>> Also, what do you think about adding an operation type (MEMCPY, XOR,
>> CRYPTO_AES, etc).  We can than validate if the operation type
>> expected is supported by the devices that exist.
>
> No objections, but this speculative support doesn't need to be in our
> initial patchset.

I don't consider it speculative.  The patch is for a generic DMA  
engine interface.  That interface should encompass all users.  I have  
a security/crypto DMA engine that I'd like to front with the generic  
DMA interface today.  Also, I believe there is another Intel group  
with an XOR engine that had a similar concept called ADMA posted a  
while ago.

http://marc.theaimsgroup.com/?t=112603120100004&r=1&w=2

>> Shouldn't we also have a dma_async_client_chan_free()?
>
> Well we could just define it to be chan_request(0) but it doesn't seem
> to be needed. Also, the allocation mechanism we have for channels is
> different from alloc/free's semantics, so it may be best to not muddy
> the water in this area.

Can you explain what the semantics are.

It's been a little while since I posted so my thoughts on the subject  
are going to take a little while to come back to me :)

- kumar
