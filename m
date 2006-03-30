From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 1/8] [I/OAT] DMA memcpy subsystem
Date: Thu, 30 Mar 2006 02:01:50 -0600
Message-ID: <F9901EAA-FA85-4C9C-94F5-BE6A9C62A4A4@kernel.crashing.org>
References: <20060311022759.3950.58788.stgit@gitlost.site> <20060311022919.3950.43835.stgit@gitlost.site> <2FF801BB-F96C-4864-AC44-09B4B92531F7@kernel.crashing.org> <c0a09e5c0603281044i57730c66ye08c45aadd352cf8@mail.gmail.com> <D760971F-3C6A-400B-99EA-E95358B37F82@kernel.crashing.org> <c0a09e5c0603281401uaeea6aci57054aef444a5e1@mail.gmail.com> <3B202D51-1683-465D-AE3D-DE301017BD69@kernel.crashing.org> <c0a09e5c0603291505h10f062d5qd6e1861ef052d07b@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v746.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Chris Leech" <christopher.leech@intel.com>,
	"linux kernel mailing list" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751320AbWC3IBj@vger.kernel.org>
In-Reply-To: <c0a09e5c0603291505h10f062d5qd6e1861ef052d07b@mail.gmail.com>
To: "Andrew Grover" <andy.grover@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mar 29, 2006, at 5:05 PM, Andrew Grover wrote:

> On 3/28/06, Kumar Gala <galak@kernel.crashing.org> wrote:
>> Do you only get callback when a channel is available?
>
> Yes
>
>> How do you
>> decide to do to provide PIO to the client?
>
> The client is responsible for using any channels it gets, or falling
> back to memcpy() if it doesn't get any. (I don't understand how PIO
> comes into the picture..?)

I was under the impression that the DMA engine would provide a "sync"  
cpu based memcpy (PIO) if a real HW channel wasn't avail, if this is  
left to the client that's fine.  So how does the client know he  
should use normal memcpy()?

>> A client should only request multiple channel to handle multiple
>> concurrent operations.
>
> Correct, if there aren't any CPU concurrency issues then 1 channel
> will use the device's full bandwidth (unless some other client has
> acquired the other channels and is using them, of course.)
>
>>> This gets around the problem of DMA clients registering (and  
>>> therefore
>>> not getting) channels simply because they init before the DMA device
>>> is discovered.
>>
>> What do you expect to happen in a system in which the channels are
>> over subscribed?
>>
>> Do you expect the DMA device driver to handle scheduling of channels
>> between multiple clients?
>
> It does the simplest thing that could possibly work right now:
> channels are allocated first come first serve. When there is a need,
> it should be straightforward to allow multiple clients to share DMA
> channels.

Sounds good for a start.  Have you given any thoughts on handling  
priorities between clients?

I need to take a look at the latest patches. How would you guys like  
modifications?

- k
