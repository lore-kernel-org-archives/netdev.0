From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: dsa: don't unmask port bitmaps
Date: Thu, 26 Oct 2017 17:06:18 +0900 (KST)
Message-ID: <20171026.170618.1949112293231201383.davem@davemloft.net>
References: <87h8upeesg.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
        <be302ef8-7f12-aaf1-5f68-c4de89c7d83d@gmail.com>
        <20171024092234.GA2911@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com
To: andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024092234.GA2911@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 24 Oct 2017 11:22:34 +0200

>> In case of probe deferral, you get the full probe function to exit with
>> an error, and that usually involves freeing the recently allocated
>> dsa_switch instance, and then allocating a new one when probe is
>> re-entered, so that should not be a problem.
> 
> Hi Florian
> 
> That is the simple case. I remember having problems with more complex
> cases, D in DSA. Switches 1 and 2 probe O.K, switch 3 fail with
> EPROBE_DEFER. Switch 3, as you say, releases its dsa_switch instance,
> so will get a freshly zero'ed new instance when it probes
> again. However, switches 1 and 2 only experience the unwind at the DSA
> level. The devices are not removed and later probed again. They have a
> 'dirty' dsa_switch structure the next time they are applied.
> 
> I just think there might be potential for regressions here. But i've
> not yet looked at the details to really know if there actually is.

I realize there is still some trepidation about these patches, but it
seems like the only real way to find out if it causes regressions is
to apply them and watch carefully.

So I've applied this and if anything pops up we can easily revert.

Thanks.
