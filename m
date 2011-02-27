From: Avi Kivity <avi@redhat.com>
Subject: Re: EPT: Misconfiguration
Date: Sun, 27 Feb 2011 12:46:41 +0200
Message-ID: <4D6A2B91.5020100@redhat.com>
References: <AANLkTinjt8G=mdEZK1a3qKozHw24uN0dfy2vUckbqwSZ@mail.gmail.com> <20110121132247.GA3097@amt.cnet> <AANLkTi=kMRu+4V6cc3bZtAT-L2P5cUo0QR3wNR3Y4u6B@mail.gmail.com> <4D3F0AD1.9010903@redhat.com> <AANLkTi=RMXSHAAbnN=HykGqbUshOFX_DO4kgYXTZUAdR@mail.gmail.com> <4D3FEEDB.5070407@redhat.com> <AANLkTimhkuMeKuihwRVnphxdCejpGi3rgd3uj9Xc_70v@mail.gmail.com> <AANLkTik76qykBCS_sEDQvBr4n7=BuffiU23bYKjFTRxa@mail.gmail.com> <AANLkTikS2M2pxO09PHN8+5+cBaQ593C9H7KthQHd4tM0@mail.gmail.com> <4D57D6AC.7000608@redhat.com> <20110215171639.GA12842@amt.cnet> <AANLkTimeFf2Smj=bWDYoH0Hf+ftnbW3XjacyS2pu49_o@mail.gmail.com> <AANLkTiknMneQtYqgmX7gvXsMoSO-yiLXr-dwbEej80Uy@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marcelo Tosatti <mtosatti@redhat.com>, kvm <kvm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Ruben Kerkhof <ruben@rubenkerkhof.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <AANLkTiknMneQtYqgmX7gvXsMoSO-yiLXr-dwbEej80Uy@mail.gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Copying netdev: looks like memory corruption in the networking stack.

Archive link: http://www.spinics.net/lists/kvm/msg50651.html (for the 
attachment).

On 02/24/2011 11:15 PM, Ruben Kerkhof wrote:
> >
> >  On Tue, Feb 15, 2011 at 18:16, Marcelo Tosatti<mtosatti@redhat.com>  wrote:
>
> >>  This and the others reported. So yes, it looks something is corrupting
> >>  memory. Ruben, you can try to boot with slub_debug=ZFPU kernel option.
>
> Ok, there are now only 6 vms left on this host, and I've booted it
> with the slub_debug=ZFPU option.
> After a few hours, I got the following result:
>
> 2011-02-24T21:41:30.818496+01:00 phy005 kernel:
> =============================================================================
> 2011-02-24T21:41:30.818517+01:00 phy005 kernel: BUG kmalloc-2048 (Not
> tainted): Object padding overwritten
> 2011-02-24T21:41:30.818523+01:00 phy005 kernel:
> -----------------------------------------------------------------------------
> 2011-02-24T21:41:30.818526+01:00 phy005 kernel:
> 2011-02-24T21:41:30.818530+01:00 phy005 kernel: INFO:
> 0xffff8806230752ca-0xffff8806230752cf. First byte 0x0 instead of 0x5a
> 2011-02-24T21:41:30.818534+01:00 phy005 kernel: INFO: Allocated in
> __netdev_alloc_skb+0x34/0x51 age=2231 cpu=8 pid=0
> 2011-02-24T21:41:30.818537+01:00 phy005 kernel: INFO: Freed in
> skb_release_data+0xc9/0xce age=2368 cpu=8 pid=2159
> 2011-02-24T21:41:30.818541+01:00 phy005 kernel: INFO: Slab
> 0xffffea00157a9880 objects=15 used=13 fp=0xffff8806230752d0
> flags=0x40000000004083
> 2011-02-24T21:41:30.818545+01:00 phy005 kernel: INFO: Object
> 0xffff880623074a88 @offset=19080 fp=0xffff8806230752d0
>
> The rest of the output is attached since it's quite large.
>
> Kind regards,
>
> Ruben


-- 
error compiling committee.c: too many arguments to function

