From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Sun, 12 Aug 2012 16:09:35 +0300
Message-ID: <5027AB0F.7010102@mellanox.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com> <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com> <87boitz044.fsf@xmission.com> <20120805185031.GA18640@redhat.com> <CAJZOPZKtdvxTGvrxj+T896mEexb=yN9s1cCuqUmhhzCOvUPEnA@mail.gmail.com> <20120812102240.GG1421@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, <davem@davemloft.net>,
	<roland@kernel.org>, <netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, Erez Shitrit <erezsh@mellanox.co.il>,
	Doug Ledford <dledford@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:57077 "HELO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751816Ab2HLNKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Aug 2012 09:10:12 -0400
In-Reply-To: <20120812102240.GG1421@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/2012 13:22, Michael S. Tsirkin wrote:
> On Wed, Aug 08, 2012 at 08:23:15AM +0300, Or Gerlitz wrote:
>> >On Sun, Aug 5, 2012 at 9:50 PM, Michael S. Tsirkin<mst@redhat.com>  wrote:
>> >
>> >[...]
>>> > >So it seems that a sane solution would involve an extra level of
>>> > >indirection, with guest addresses being translated to host IB addresses.
>>> > >As long as you do this, maybe using an ethernet frame format makes sense.
>> >[...]
>> >
>> >Yep, that's among the points we're trying to make, the way you've put
>> >it makes it clearer.
>> >
>>> > >So far the things that make sense. Here are some that don't, to me:
>> >
>>> > >- Is a pdf presentation all you have in terms of documentation?
>>> > >   We are talking communication protocols here - I would expect a
>>> > >   proper spec, and some effort to standardize, otherwise where's the
>>> > >   guarantee it won't change in an incompatible way?
>> >
>> >To be precise, the solution uses 100% IPoIB wire-protocol, so we don't
>> >see a need
>> >for any spec change / standardization effort.
> Yes, I am guessing this is the real reason you pack LID/QPN
> in the MAC - to make it all local. But it's a hack really,
> and if you start storing it all in the SM you will need
> to document the format so others can inter-operate.

I'd like to review the way we generate these MAC addresses, maybe it
can be done differently.


>
>
>> >This might go to the 1stpoint you've
>> >brought... improve the documentation, will do that. The pdf you looked
>> >at was presentedin a conference.
>>
>>> > >   Other things that I would expect to be addressed in such a spec is
>>> > >   interaction with other IPoIB features, such as connected
>>> > >   mode, checksum offloading etc, and IB features such as multipath etc.
>> >
>> >For the eipoib interface, it doesn't really matters if the underlyind
>> >ipoib clones used by it (we call them VIFs) use connected or datagram
>> >mode, what does matter is the MTU and offload features supported by
>> >these VIFs, for which the eipoib interface will have the min among all
>> >these VIFs. Since for a given eipoib nic, all its VIFs must originated
>> >from the same IPoIB PIF (e.g ib0) its easy admin job to make sure they
>> >all have the same mtu / features which are needed for that eipoib nic,
>> >e.g by using the same mode (connected/datagram for all of them), hope
>> >this is clear.
>> >
> Just pointing out all this needs to be documented.

OK, will do

>
>
>>> > >- The way you encode LID/QPN in the MAC seems questionable. IIRC there's
>>> > >   more to IB addressing than just the LID.  Since everyone on the subnet
>>> > >   need access to this translation, I think it makes sense to store it in
>>> > >   the SM. I think this would also obviate some IPv4 specific hacks in kernel.
>> >
>> >The idead beyond the encoding was uniqueness, LID/QPN is unique per IB
>> >HCA end-node.
> But then it breaks with VM migration, IB failover, softmac setting in guest, probably more?

With the current design/code the remote mac of a VM changes, when that 
VM migrates or IB
LIDs are changed. As for softmac setting in the guest, we  don't send 
the guest MAC on the wire
anyway, since the Ethernet header is removed.

Or.
